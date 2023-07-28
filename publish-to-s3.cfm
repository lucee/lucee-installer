<cfscript>
    systemOutput( "Publish Installers to s3, using #server.lucee.version#" );
    systemOutput( " - for installers for Lucee #server.system.environment.lucee_version# ", true);

    currDir = getDirectoryFromPath( getCurrentTemplatePath() );
    files = directoryList( path=currDir, listinfo=query );
    systemOutput( "", true );

    loop query="files" {
        systemOutput( files.names & " " & numberFormat(files.size), true);
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
    if (! DirectoryExists( trg.dir ) )
        throw "DirectoryExists failed for s3 bucket [#s3_bucket#]"; // it usually will throw an error, rather than even reach this throw, if it fails

    echo("done!");
</cfscript>