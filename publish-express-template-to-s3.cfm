<cfscript>
	log = [ "## Publishing installers to S3" ];

	function logger( message ){
		systemOutput( arguments.message, true );
		arrayAppend( log, arguments.message );
	}

	function writeOutMarkdown( log ){
		fileWrite( server.system.environment.GITHUB_STEP_SUMMARY, ArrayToList( arguments.log, chr( 10 ) ) );
	}

	logger( "Publishing Lucee Express Templates to s3, using #server.lucee.version#" );
	dry_run = server.system.environment.DRY_RUN ?: "";
	currDir = getDirectoryFromPath( getCurrentTemplatePath() );

	if ( len(server.system.environment.tomcat9_version) eq 0 )
		throw "env.tomcat9_version was empty";
	if ( len(server.system.environment.tomcat10_version) eq 0 )
		throw "env.tomcat10_version was empty";
	if ( len(server.system.environment.tomcat11_version) eq 0 )
		throw "env.tomcat11_version was empty";

	files = directoryList( path=currDir, listInfo="query" );
	logger( "" );

	loop query="files" {
		if ( files.name contains ".zip" )
			logger( files.name & " " & numberFormat( files.size / 1024 / 1024 ) );
	}

	// do we have the s3 extension?
	s3ExtVersion = extensionList().filter( function(row){ return row.name contains "s3"; }).version;
	if ( s3ExtVersion eq "" ){
		logger( "ERROR! The S3 Extension isn't installed!" );
		writeOutMarkdown( log );
		throw "The S3 Extension isn't installed!"; // fatal
	} else {
		logger( "Using S3 Extension: #s3ExtVersion#" );
	}

	// check for S3 credentials
	if ( isEmpty( server.system.environment.S3_ACCESS_ID_DOWNLOAD ?:"" )
			|| isEmpty( server.system.environment.S3_SECRET_KEY_DOWNLOAD ?: "") ) {
		logger( "no S3 credentials defined to upload to S3");
		writeOutMarkdown( log );
		if (dry_run) return;
		throw "no S3 credentials defined to upload to S3, DRY_RUN was false";
	}

	trg = {};
	s3_bucket = "lucee-downloads";
	s3_dest = "s3://#server.system.environment.S3_ACCESS_ID_DOWNLOAD#:"
		& "#server.system.environment.S3_SECRET_KEY_DOWNLOAD#@/#s3_bucket#/";
	logger( "Testing S3 Bucket Access" );
	if ( !directoryExists( s3_dest ) ){
		fail = "DirectoryExists failed for s3 bucket [#s3_bucket#]";
		logger( fail );
		writeOutMarkdown( log );
		throw fail;
	}
	logger ("" );
	s3_express_folder = "express-templates/";
	s3_dest = s3_dest & s3_express_folder;

	logger("Dry run was [#dry_run#]");
	if ( dry_run ) {
		writeOutMarkdown( log );
	}

	if ( !dry_run && !directoryExists( s3_dest ) ){
		directoryCreate( s3_dest );
	}

	loop list="tomcat9,tomcat10_1,tomcat11" item="tomcat" {
		src = "lucee-#tomcat#-template.zip";
		switch (tomcat){
			case "tomcat9":
				trg = "lucee-tomcat-#server.system.environment.tomcat9_version#-template.zip";
				break;
			case "tomcat10_1":
				trg = "lucee-tomcat-#server.system.environment.tomcat10_version#-template.zip";
				break;
			case "tomcat11":
				trg = "lucee-tomcat-#server.system.environment.tomcat11_version#-template.zip";
				break;
			default:
				throw "unknown tomcat version [#tomcat#]";
		}
			
		if ( !fileExists( src )){
			logger( "Error [" & src & "] express template missing?" );
		} else {
			logger( "[" & trg & "] to be uploaded on s3" );
			if ( !dry_run )
				fileCopy( src, s3_dest & trg );
			logger( "https://cdn.lucee.org/#s3_express_folder##trg#" );
			if ( dry_run )
				logger( "-- would have been uploaded, DRY_RUN was true" );
			else
				logger( "-- was uploaded" );
		}
		logger ("" );
	}
	logger( "Publishing step complete!" );

	writeOutMarkdown( log );
</cfscript>