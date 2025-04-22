#!/usr/bin/env python3
"""
     Wordnik.com's Swagger generic API client.
"""

import re
import urllib.request
import urllib.error
import urllib.parse
import http.client
import http.cookiejar
import json
import time
import datetime

from paslib.api import *


class ApiClient:
    """Generic API client for Swagger client library builds"""

    def getJSMilliseconds(self, aDateTime):
        return int(time.mktime(aDateTime.timetuple()) * 1000)

    def __init__(self, apiKey=None, apiServer=None):
        if apiKey == None:
            raise Exception('You must pass an apiKey when instantiating the '
                            'APIClient')
        self.apiKey = apiKey
        self.apiServer = apiServer
        self.cookie = None
        self.opener = None
        self.debugOption = False
        self.cj = http.cookiejar.CookieJar()

    def closeOpener(self):
        if self.opener != None:
            self.opener.close()
            self.opener = None


    def callAPI(self, resourcePath, method, queryParams, postData,
                headerParams=None):

        url = resourcePath
        headers = {}
        if headerParams:
            for param, value in headerParams.items():
                headers[param] = value

        #headers['Content-type'] = 'application/json'
        headers['api_key'] = self.apiKey

        #if self.cookie:
        #    headers['Cookie'] = self.cookie

        data = None

        if queryParams:
            # Need to remove None values, these should not be sent
            sentQueryParams = {}
            for param, value in queryParams.items():
                if value != None:
                    sentQueryParams[param] = value
            url = url + '?' + urllib.parse.urlencode(sentQueryParams)

        if method in ['GET']:

            #Options to add statements later on and for compatibility
            pass

        elif method in ['PATCH', 'POST', 'PUT', 'DELETE']:

            if postData:
                headers['Content-type'] = 'application/json'
                data = self.serialize(postData)
                data = json.dumps(data)
                if self.debugOption:
                    print("Post: " + data)

        else:
            raise Exception('Method ' + method + ' is not recognized.')

        if data:
            data = data.encode('utf-8')

        requestParams = MethodRequest(method=method, url=url,
                                       headers=headers, data=data)

        # Make the request

        if self.opener == None:
            self.opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(self.cj))
        request = self.opener.open(requestParams)
        # request = urllib.request.urlopen(requestParams)
        encoding = request.headers.get_content_charset()
        if not encoding:
            encoding = 'iso-8859-1'
        response = request.read().decode(encoding)
        if self.debugOption:
            print("Response: " + response)
        if len(self.cj) > 0:
            cookies = list(self.cj)
            self.cookie = cookies[0]

        try:
            data = json.loads(response)
        except ValueError:  # PUT requests don't return anything
            data = None

        return data

    def toPathValue(self, obj):
        """Convert a string or object to a path-friendly value
        Args:
            obj -- object or string value
        Returns:
            string -- quoted value
        """
        if type(obj) == list:
            return urllib.parse.quote(','.join(obj))
        else:
            return urllib.parse.quote(str(obj))

    def sanitizeForSerialization(self, obj):
        """Dump an object into JSON for POSTing."""

        if type(obj) == type(None):
            return None
        elif type(obj) in [str, int, float, bool]:
            return obj
        elif type(obj) == list:
            return [self.sanitizeForSerialization(subObj) for subObj in obj]
        elif type(obj) == datetime.datetime:
            return obj.isoformat()
        else:
            if type(obj) == dict:
                objDict = obj
            else:
                objDict = obj.__dict__
            return {key: self.sanitizeForSerialization(val)
                    for (key, val) in objDict.items()
                    if (key != 'swaggerTypes') or (val != None)}

    def serialize(self, obj):
        # Wenn das Objekt aus PUM kommt, dann hat es das Attribut
        if hasattr(obj, 'swaggerTypes'):
            return {attr: self.serializeAttribute(getattr(obj, attr), attrType)
                    for attr, attrType in obj.swaggerTypes.items()
                    if (getattr(obj, attr) != None)}
        else:
            return self.serializeAttribute(obj, None)

    def timezoneName(self,secondsOffset):
        tzName = ""
        hours = int(secondsOffset / 3600)
        if hours >= 0:
            tzName += "+"
        else:
            tzName += "-"
        tzName += str(abs(hours)).zfill(2)
        tzName += ":00"
        return tzName

    def localTimezoneName(self):
        if time.daylight:
            offset = 0 - time.altzone
        else:
            offset = 0 - time.timezone
        return self.timezoneName(offset)

    def timezoneNameFromDateTime(self,aDateTime: datetime):
        if aDateTime.utcoffset() is None:
            return self.localTimezoneName()
        else:
            return self.timezoneName(aDateTime.utcoffset().total_seconds())

    def dateTimeAsRFC3339(self, pDateTime):
        baseString = pDateTime.strftime('%Y-%m-%dT%H:%M:%S')
        baseString += "." + str(int(pDateTime.microsecond / 1000)).zfill(3)
        baseString += self.timezoneNameFromDateTime(pDateTime)
        return baseString

    def serializeAttribute(self, attrValue, attrType):
        if type(attrValue) == type(None):
            return None
        elif type(attrValue) in [str, int, float, bool]:
            return attrValue
        elif type(attrValue) == list:
            return [self.serialize(subObj) for subObj in attrValue]
        elif type(attrValue) == datetime.datetime:
            if attrType == 'date':
                return attrValue.strftime('%Y-%m-%d')
            elif attrType == 'time:':
                return attrValue.strftime('%H:%M:%S')
            else:
                return self.dateTimeAsRFC3339(attrValue)
        elif (type(attrValue) == datetime.date) and (attrType == 'date'):
            return attrValue.strftime('%Y-%m-%d')
        elif (type(attrValue) == datetime.time) and (attrType == 'time'):
            return attrValue.strftime('%H:%M:%S')
        else:
            if type(attrValue) == dict:
                objDict = attrValue
            else:
                objDict = attrValue.__dict__
            return {key: self.serialize(val)
                    for (key, val) in objDict.items()
                    if (key != 'swaggerTypes') or (val != None)}


    def _iso8601Format(self, timesep, microsecond, offset, zulu):
        """Format for parsing a datetime string with given properties.
        Args:
            timesep -- string separating time from date ('T' or 't')
            microsecond -- microsecond portion of time ('.XXX')
            offset -- time offset (+/-XX:XX) or None
            zulu -- 'Z' or 'z' for UTC, or None for time offset (+/-XX:XX)
        Returns:
            str - format string for datetime.strptime"""

        return '%Y-%m-%d{}%H:%M:%S{}{}'.format(
            timesep,
            '.%f' if microsecond else '',
            zulu or ('%z' if offset else ''))

    # http://xml2rfc.ietf.org/public/rfc/html/rfc3339.html#anchor14
    _iso8601Regex = re.compile(
        r'^\d\d\d\d-\d\d-\d\d([Tt])\d\d:\d\d:\d\d(\.\d+)?(([Zz])|(\+|-)\d\d:?\d\d)?$')

    _TimeStampRegex = re.compile(r'^[\d]+')

    _DateRegex = re.compile(r'^\d\d\d\d-\d\d-\d\d')

    _TimeRegex = re.compile(r'^\d\d:\d\d:\d\d')

    def _parseDatetime(self, d):
        if d is None:
            return None
        m = ApiClient._iso8601Regex.match(d)
        if not m:
            raise Exception('datetime regex match failed "%s"' % d)
        timesep, microsecond, offset, zulu, plusminus = m.groups()
        format = self._iso8601Format(timesep, microsecond, offset, zulu)
        if offset and not zulu:
            d = d.rsplit(sep=plusminus, maxsplit=1)[0] + offset.replace(':', '')
        return datetime.datetime.strptime(d, format)

    def _parseJavascriptTimeStamp(self, d):
        if (d == 0):
            return None
        return datetime.datetime.fromtimestamp(d/1000.0)

    def _parseDate(self, d):
        if d is None:
            return None
        m = ApiClient._DateRegex.match(d)
        if not m:
            raise Exception('date regex match failed "%s"' % d)
        value = datetime.datetime.strptime(d, '%Y-%m-%d')
        return value

    def _parseTime(self, d):
        print(d)
        if d is None:
            return None
        m = ApiClient._TimeRegex.match(d)
        if not m:
            raise Exception('time regex match failed "%s"' % d)
        value = datetime.datetime.strptime(d, '%H:%M:%S')
        return value

    def deserialize(self, obj, objClass):
        """Derialize a JSON string into an object.
        Args:
            obj -- string or object to be deserialized
            objClass -- class literal for deserialzied object, or string
                of class name
        Returns:
            object -- deserialized object"""

        # Have to accept objClass as string or actual type. Type could be a
        # native Python type, or one of the model classes.
        if type(objClass) == str:
            if 'list[' in objClass:
                match = re.match('list\[(.*)\]', objClass)
                subClass = match.group(1)
                return [self.deserialize(subObj, subClass) for subObj in obj]

            if (objClass in ['int', 'float', 'dict', 'list', 'str', 'bool', 'datetime']):
                objClass = eval(objClass)
            else:  # not a native type, must be model class
                objClass = eval(objClass)

        if objClass in [int, float, dict, list, str, bool]:
            return objClass(obj)
        elif objClass == datetime:
            return self._parseDatetime(obj)

        instance = objClass()

        for attr, attrType in instance.swaggerTypes.items():

            if attr in obj:
                value = obj[attr]
                if attrType in ['str', 'int', 'float', 'bool']:
                    attrType = eval(attrType)
                    try:
                        value = attrType(value)
                    except UnicodeEncodeError:
                        value = str(value)
                    except TypeError:
                        value = value
                    setattr(instance, attr, value)
                elif (attrType == 'datetime'):
                    setattr(instance, attr, self._parseDatetime(value))
                elif (attrType == 'date'):
                    aDateTime = self._parseDate(value)
                    setattr(instance, attr, aDateTime)
                elif (attrType == 'time'):
                    setattr(instance, attr, self._parseTime(value))
                elif 'list[' in attrType:
                    match = re.match('list\[(.*)\]', attrType)
                    subClass = match.group(1)
                    subValues = []
                    if not value:
                        setattr(instance, attr, None)
                    else:
                        for subValue in value:
                            subValues.append(self.deserialize(subValue,subClass))
                    setattr(instance, attr, subValues)
                else:
                    setattr(instance, attr, self.deserialize(value,attrType))

        return instance


class MethodRequest(urllib.request.Request):

    def __init__(self, *args, **kwargs):
        """Construct a MethodRequest. Usage is the same as for
        `urllib.Request` except it also takes an optional `method`
        keyword argument. If supplied, `method` will be used instead of
        the default."""

        if 'method' in kwargs:
            self.method = kwargs.pop('method')
        return urllib.request.Request.__init__(self, *args, **kwargs)

    def get_method(self):
        return getattr(self, 'method', urllib.request.Request.get_method(self))