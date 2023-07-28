<cfscript>

	log = [ "## Publishing installers to S3" ];

	function logger( message, out ){
		systemOutput( arguments.message, true );
		arrayAppend( log, arguments.message );
	}

	logger( "Publish Installers to s3, using #server.lucee.version#", true );
	logger( " - for installers for Lucee #server.system.environment.lucee_version# ", true );

	version = server.system.environment.lucee_version;

	currDir = getDirectoryFromPath( getCurrentTemplatePath() );

	files = directoryList( path=currDir, listinfo="query" );
	logger( "", true );

	loop query="files" {
		if ( files.name contains ".exe" or files.name contains ".run" )
			logger( files.name & " " & numberFormat( files.size / 1024 / 1024 ), true );
	}

	// do we have the s3 extension?
	s3ExtVersion = extensionList().filter( function(row){ return row.name contains "s3"; }).version;
	if ( s3Extversion eq "" ){
		logger( "ERROR! The S3 Extension isn't installed!", true );
		return;
		//throw "The S3 Extension isn't installed!"; // fatal
	} else {
		logger( "Using S3 Extension: #s3ExtVersion#", true );
	}

	// check for S3 credentials
	if ( isNull( server.system.environment.S3_ACCESS_ID_DOWNLOAD )
			|| isNull( server.system.environment.S3_SECRET_KEY_DOWNLOAD ) ) {
		logger( "no S3 credentials defined to upload to S3", 1, 1 );
		return;
	}

	trg = {};
	s3_bucket = "lucee-downloads";
	trg.dir = "s3://#server.system.environment.S3_ACCESS_ID_DOWNLOAD#:#server.system.environment.S3_SECRET_KEY_DOWNLOAD#@/#s3_bucket#/";
	logger( "Testing S3 Bucket Access", 1, 1 );
	if ( !directoryExists( trg.dir ) )
		throw "DirectoryExists failed for s3 bucket [#s3_bucket#]"; // it usually will throw an error, rather than even reach this throw, if it fails

	trg.linux = "lucee-#version#-linux-x64-installer.run";
	trg.windows = "lucee-#version#-windows-x64-installer.exe";

	loop list="windows,linux" item="os" {
		if ( !fileExists( currDir & trg[ os ] )){
			logger( trg[ os ] & " installer missing?", true );
		} else if ( fileExists( trg.dir & trg[ os ] ) ){
			logger( trg[ os ] & " already on s3", true );
		} else {
			logger( trg[ os ] & " to be uploaded on s3", true );
			fileCopy( currDir & trg[os], trg.dir & trg[ os ] );
			logger ("-- was uploaded", true );
		}
	}

	logger( "Publishing step complete!" );
	
	fileWrite( server.system.environment.GITHUB_STEP_SUMMARY, ArrayToList( log, chr(10) ) );
</cfscript>