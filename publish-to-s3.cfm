<cfscript>
	systemOutput( "Publish Installers to s3, using #server.lucee.version#", true );
	systemOutput( " - for installers for Lucee #server.system.environment.lucee_version# ", true );

	version = server.system.environment.lucee_version;

	currDir = getDirectoryFromPath( getCurrentTemplatePath() );

	systemOutput(currDir, true);
	systemOutput(getContextRoot(), true);
	systemOutput(expandPath("/"), true);
	
	files = directoryList( path=currDir, listinfo="query" );
	systemOutput( "", true );

	loop query="files" {
		systemOutput( files.name & " " & numberFormat( files.size / 1024 / 1024 ), true);
	}

	// do we have the s3 extension?
	s3ExtVersion = extensionList().filter( function(row){ return row.name contains "s3"; }).version;
	if ( s3Extversion eq "" ){
		SystemOutput( "ERROR! The S3 Extension isn't installed!", true );
		return;
		//throw "The S3 Extension isn't installed!"; // fatal
	} else {
		SystemOutput( "Using S3 Extension: #s3ExtVersion#", true );
	}

	// check for S3 credentials
	if ( isNull( server.system.environment.S3_ACCESS_ID_DOWNLOAD )
			|| isNull( server.system.environment.S3_SECRET_KEY_DOWNLOAD ) ) {
		SystemOutput( "no S3 credentials defined to upload to S3", 1, 1 );
		return;
	}

	trg = {};
	s3_bucket = "lucee-downloads";
	trg.dir = "s3://#server.system.environment.S3_ACCESS_ID_DOWNLOAD#:#server.system.environment.S3_SECRET_KEY_DOWNLOAD#@/#s3_bucket#/";
	SystemOutput( "Testing S3 Bucket Access", 1, 1 );
	if ( !directoryExists( trg.dir ) )
		throw "DirectoryExists failed for s3 bucket [#s3_bucket#]"; // it usually will throw an error, rather than even reach this throw, if it fails

	trg.linux = "lucee-#version#-linux-x64-installer.run";
	trg.windows = "lucee-#version#-windows-x64-installer.exe";

	loop list="windows,linux" item="os" {
		if ( fileExists( trg.dir & trg[ os ] ) ){
			systemOutput( trg[ os ] & " already on s3", true );
		} else {
			systemOutput( trg[ os ] & " to be uploaded on s3", true );
			// fileCopy( currDir & trg[os], trg.dir & trg[ os ] );
			systemOutput ("-- uploaded", true );
		}
	}

	echo("done!");
</cfscript>