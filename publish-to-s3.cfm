<cfscript>

	log = [ "## Publishing installers to S3" ];

	function logger( message ){
		systemOutput( arguments.message, true );
		arrayAppend( log, arguments.message );
	}

	function writeoutMarkdown( log ){
		fileWrite( server.system.environment.GITHUB_STEP_SUMMARY, ArrayToList( arguments.log, chr( 10 ) ) );
	}

	logger( "Publish Installers to s3, using #server.lucee.version#" );
	logger( " - for installers for Lucee #server.system.environment.LUCEE_INSTALLER_VERSION# " );

	version = server.system.environment.LUCEE_INSTALLER_VERSION;
	dry_run = server.system.environment.DRY_RUN ?: "";

	currDir = getDirectoryFromPath( getCurrentTemplatePath() );

	files = directoryList( path=currDir, listinfo="query" );
	logger( "" );

	loop query="files" {
		if ( files.name contains ".exe" or files.name contains ".run" )
			logger( files.name & " " & numberFormat( files.size / 1024 / 1024 ) );
	}

	// do we have the s3 extension?
	s3ExtVersion = extensionList().filter( function(row){ return row.name contains "s3"; }).version;
	if ( s3Extversion eq "" ){
		logger( "ERROR! The S3 Extension isn't installed!" );
		writeoutMarkdown( log );
		return;
		//throw "The S3 Extension isn't installed!"; // fatal
	} else {
		logger( "Using S3 Extension: #s3ExtVersion#" );
	}

	// check for S3 credentials
	if ( isNull( server.system.environment.S3_ACCESS_ID_DOWNLOAD )
			|| isNull( server.system.environment.S3_SECRET_KEY_DOWNLOAD ) ) {
		logger( "no S3 credentials defined to upload to S3");
		writeoutMarkdown( log );
		return;
	}

	logger("Dry run was [#dry_run#]");
	if ( dry_run ) {
		writeOutMarkdown( log );
	}

	trg = {};
	s3_bucket = "lucee-downloads";
	trg.dir = "s3://#server.system.environment.S3_ACCESS_ID_DOWNLOAD#:#server.system.environment.S3_SECRET_KEY_DOWNLOAD#@/#s3_bucket#/";
	logger( "Testing S3 Bucket Access" );
	if ( !directoryExists( trg.dir ) ){
		fail = "DirectoryExists failed for s3 bucket [#s3_bucket#]";
		logger( fail );
		writeoutMarkdown( log );
		throw fail; 
	}
	logger ("" );

	trg['linux-x64'] =   "lucee-#version#-linux-x64-installer.run";
	trg['linux-aarch64'] = "lucee-#version#-linux-aarch64-installer.run";
	trg.windows =        "lucee-#version#-windows-x64-installer.exe";

	loop list="windows,linux-x64,linux-aarch64" item="os" {
		if ( !fileExists( currDir & trg[ os ] )){
			logger( trg[ os ] & " installer missing?" );
		} else if ( fileExists( trg.dir & trg[ os ] ) ){
			logger( trg[ os ] & " already on s3" );
			logger ("https://cdn.lucee.org/#trg[os]#");
		} else {
			logger( trg[ os ] & " to be uploaded on s3" );
			if ( !dry_run )
				fileCopy( currDir & trg[os], trg.dir & trg[ os ] );
				logger ("https://cdn.lucee.org/#trg[os]#");
			if ( dry_run )
				logger( "-- would have been uploaded, DRY_RUN was true" );
			else
				logger( "-- was uploaded" );
		}
		logger ("" );
	}
	logger( "Publishing step complete!" );

	writeoutMarkdown( log );
</cfscript>