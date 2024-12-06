product management
downloadDirectoryNameFor: productName
	| gemVersionReport cpuKind |
	gemVersionReport := System gemVersionReport.
	cpuKind := gemVersionReport at: 'cpuKind'.
	(gemVersionReport at: 'osName') = 'Darwin'
		ifTrue: [ 
			cpuKind = 'x86_64'
				ifTrue: [ cpuKind := 'i386' ] ]
		ifFalse: [
		    cpuKind = 'aarch64'
        				ifTrue: [ cpuKind := 'arm64' ] ]
		].
	^ 'GemStone64Bit' , productName , '-' , cpuKind , '.'
		, (gemVersionReport at: 'osName')