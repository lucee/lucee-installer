<cfscript>

	tmpDir = getDirectoryFromPath(getCurrentTemplatePath()) & "tmp-installer/";
	log = [];
	srcVersion = server.system.environment.lucee_installer_version;	
	version = listToArray( srcVersion,"." );
	
	tomcat_version = "9.0";
	java_version = 11;
	tomcat_win_exe = "tomcat9w.exe";

	if ( version[ 1 ] gt 6  ||
		(version[ 1 ] gte 6 && version[ 2 ] gte 1 )){
		java_version = 21; // 6.1 onwards
	}

	if ( version[ 1 ] gt 6  ||
		(version[ 1 ] gte 6 && version[ 2 ] gte 2 )){
		tomcat_version = "10.1"; // 6.2 onwards
		tomcat_win_exe = "tomcat10w.exe";
	}

	logger("Using Java version #java_version# for Lucee #srcVersion#");
	logger("Using Tomcat version #tomcat_version# for Lucee #srcVersion#");

	tomcat = getTomcatVersion( tomcat_version );
	java = getJavaVersion( java_version );

	installbuilder_template = getDirectoryFromPath( getCurrentTemplatePath() ) & "lucee/lucee.xml";
	template = fileRead(installbuilder_template);
	template = Replace( template, "<origin>${installdir}/tomcat/bin/TOMCAT_WIN_EXE</origin>", "<origin>${installdir}/tomcat/bin/#tomcat_win_exe#</origin>" );
	if (tomcat_version eq 9){
		template = Replace( template, "<origin>${installdir}/mod_cfml/mod_cfml-valve_*</origin>", "<origin>${installdir}/mod_cfml/mod_cfml-valve_v1*</origin>" );
	} else {
		template = Replace( template, "<origin>${installdir}/mod_cfml/mod_cfml-valve_*</origin>", "<origin>${installdir}/mod_cfml/mod_cfml-valve_v2*</origin>" );
	}
	fileWrite( installbuilder_template, template );

	windows_service_bat = getDirectoryFromPath( getCurrentTemplatePath() ) & "lucee/tomcat9/tomcat-lucee-conf/bin/service.bat";
	template = fileRead(windows_service_bat);
	template = Replace( template, "set DEFAULT_SERVICE_NAME=Tomcat9", "set DEFAULT_SERVICE_NAME=#mid(tomcat_win_exe, 1, len(tomcat_win_exe)-5)#" );
	template = Replace( template, "Lucee Apache Tomcat 9.0 ", "Lucee #srcVersion# Apache Tomcat #tomcat._version# ", "all" );
	fileWrite( windows_service_bat, template );

	tomcat_web_xml_header = "";
	switch ( tomcat_version ){
		case "9.0":
			break;
		case "10.1":
			tomcat_web_xml_header='<web-app xmlns="https://jakarta.ee/xml/ns/jakartaee"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="https://jakarta.ee/xml/ns/jakartaee
                      https://jakarta.ee/xml/ns/jakartaee/web-app_6_0.xsd"
  version="6.0">';
  			FileCopy("lucee/tomcat10/conf/catalina.properties", "lucee/tomcat9/tomcat-lucee-conf/conf/catalina.properties");
			addJavaxJars(getDirectoryFromPath( getCurrentTemplatePath() ) & "lucee/lucee/lib/");
			break;
		default:
			throw "Unsupported Tomcat version [#tomcat_version#]";
	}

	tomcat_9_web_xml_header ='<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  xsi:schemaLocation="http://xmlns.jcp.org/xml/ns/javaee
                      http://xmlns.jcp.org/xml/ns/javaee/web-app_4_0.xsd"
  version="4.0">';

	if ( len( tomcat_web_xml_header ) ){
		web_xml = "lucee/tomcat9/tomcat-lucee-conf/conf/web.xml";
		template = fileRead(web_xml);
		template = Replace( template, tomcat_9_web_xml_header, tomcat_web_xml_header );
		template = Replace( template, ">lucee.loader.servlet.", ">lucee.loader.servlet.jakarta.", "all" );
		
		fileWrite( web_xml, template );
	}

	
	//dump(java);
	//dump(tomcat);

	extractArchive( "zip", java.windows.archive , "jre/jre64-win/jre/" );
	extractArchive( "tgz", java.linux.archive , "jre/jre64-lin/jre/" );
	extractArchive( "zip", tomcat.windows.archive , "src-tomcat/windows/" );
	extractArchive( "tgz", tomcat.linux.archive , "src-tomcat/linux/" );

	directoryDelete( "src-tomcat/linux/webapps", true );
	directoryDelete( "src-tomcat/windows/webapps", true );

	//dump( log );
	writeoutMarkdown(log);

	function extractArchive( format, src, dest ){

		arguments.dest = getDirectoryFromPath( getCurrentTemplatePath() ) & arguments.dest;
		var tmpDest = getTempDirectory() & "tmp-installer-" & createUUID() & "/";
		if ( directoryExists( tmpDest ) )
			directoryDelete( tmpDest );
		directoryCreate( tmpdest );
		logger(" extracting [#arguments.src# ] into [#tmpDest#]" );
		_extract( arguments.format, arguments.src, tmpDest );

		/*
		if ( arguments.format != "zip" ){
			applyPermissions( arguments.src, tmpDest );
		}
		*/

		var files = directoryList(tmpDest, true);

		if ( directoryExists( arguments.dest ) )
			directoryDelete( arguments.dest, true );
		logger("copying [#files[ 1 ]# ] into [#arguments.dest#]" );
		directoryCopy( files[ 1 ], arguments.dest, true );

		directoryDelete( tmpDest, true );
	}

	function _extract( format, src, tmpDest ){
		switch ( arguments.format ){
			case "zip":
				extract( arguments.format, arguments.src, arguments.tmpDest );
				break;
			case "tgz":
				var out = "";
				var error = "";
				// use execute due to https://luceeserver.atlassian.net/browse/LDEV-5034
				execute name="tar" 
					arguments="-xzvf #arguments.src# -C #arguments.tmpDest#" 
					variable="local.out" 
					errorVariable="local.error"
					directory=arguments.tmpDest;
				if ( len( local.error ) ) throw local.error;
				// logger( local.out );
				break;
			default:
				throw "_extract: unsupported format (#arguments.format#)";
		}
		return true;
	};

	function addJavaxJars(jarPath){
		// tomcat 10+ uses jarkarta but needs the javax servlet jars too
		logger( "Adding javax jars to [#jarPath#]" );
		var jars = [
			"https://repo1.maven.org/maven2/javax/servlet/javax.servlet-api/4.0.1/javax.servlet-api-4.0.1.jar",
			"https://repo1.maven.org/maven2/javax/servlet/jsp/javax.servlet.jsp-api/2.3.3/javax.servlet.jsp-api-2.3.3.jar",
			"https://repo1.maven.org/maven2/javax/el/javax.el-api/3.0.0/javax.el-api-3.0.0.jar"
		];

		for (var jar in jars){
			logger(chr(9) & jar);
			http method="get" url=jar path=arguments.jarPath file=listlast(jar,"/") throwOnError=true;
		}
	}

	/*
	// lucee ignores permissions when extracting files
	function applyPermissions( src, dest ){
		systemOutput( "Manually applying file system permissions", true );
		var files = directoryList( path="tgz://" & src, recurse=true, listinfo="query");
		var dir ="";
		var file = "";

		systemOutput( dest, true );
		var destFiles = directoryList( path=dest, recurse=false, listinfo="query");
		for ( var d in destFiles ) {
			systemOutput( d, true );
		}

		systemOutput( "", true );
		systemOutput( "loop thru files", true );
		
		loop query="files" {
			dir = mid(files.directory, find( "!", files.directory) + 2 );
			//if ( files.mode != "644" )
			systemOutput( "#dir# #files.name# #files.size# #files.type# #files.mode#", true );

			file = arguments.dest & mid( dir, 2 ) & "/" & files.name;
			systemOutput( file, true );
			//systemOutput( fileExists( file ), true );
			fileSetAccessMode( file , files.mode );
			if ( files.type == "file" ){
				var mode = fileInfo( file ).mode;
			} else {
				var mode = directoryInfo( file ).mode;
			}
			if ( mode != files.mode) {
				throw "Permissions error [#File#] is [#mode#] should be [#files.mode#]";
			}
			
		}
	}
	*/


	function getTomcatVersion( required string version ){
		var tomcat_metadata = "https://repo1.maven.org/maven2/org/apache/tomcat/embed/tomcat-embed-core/maven-metadata.xml"

		http method="get" url=tomcat_metadata;

		var releases = xmlParse(cfhttp.filecontent);
		var srcVersions = XmlSearch(releases,"/metadata/versioning/versions/");
		var versions = [];
		for ( var v in srcVersions[1].xmlChildren ) {
			// ignore the m3 type versions
			if ( Find( arguments.version, v.xmlText) ==1
					&& listLen(v.xmlText, "." ) eq 3
					&& isNumeric( listLast( v.xmlText, "." ) ) ) {
				arrayAppend( versions, listLast( v.xmlText, "." ) );
			}
		}
		if ( ArrayLen (versions ) ==0 )
			throw "no versions found matching [#arguments.version#]";

		ArraySort( versions, "numeric", "desc" );
		var latest_version = arguments.version & "." & versions[ 1 ];
		var baseUrl = "https://dlcdn.apache.org/tomcat/tomcat-#listFirst(arguments.version,".")#/v#latest_version#/bin/";

		var tomcat = {
			"windows": {
				"url": baseUrl & "apache-tomcat-" & latest_version & "-windows-x64.zip",
			},
			"linux": {
				"url": baseUrl & "apache-tomcat-" & latest_version & ".tar.gz",
			},
			"_version": latest_version
		};

		for ( var os in tomcat ){
			if ( left( os, 1 ) eq "_" ) continue; // ignore _version
			var download_url = tomcat[os].url;
			var filename = listLast( download_url, "/" );

			http method="get" url=download_url path=getTempDirectory() file=filename throwOnError=true;
			var info = fileInfo(getTempDirectory() & filename);

			logger("downloaded [#info.path#], #numberformat(int(info.size/1024/1024))# Mb");
			tomcat[os]["archive"] = info.path;
		}
		return tomcat;
	}

	function getJavaVersion( required string version ){
		var java = {
			"windows": {
				"api": "https://api.adoptium.net/v3/assets/latest/#java_version#/hotspot?architecture=x64&os=windows&vendor=eclipse"
			},
			"linux": {
				"api": "https://api.adoptium.net/v3/assets/latest/#java_version#/hotspot?architecture=x64&os=linux&vendor=eclipse"
			}
		}
		for ( var os in java ){
			http method="get" url=java[os].api;
			java[os]["url"] = getJava( cfhttp.filecontent, "jre", "jdk");

			var download_url = java[os].url;
			var filename = listLast( download_url, "/" );

			http method="get" url=download_url path=getTempDirectory() file=filename throwOnError=true;
			var info = fileInfo(getTempDirectory() & filename);

			logger("downloaded [#info.path#], #numberformat(int(info.size/1024/1024))# Mb");
			java[os]["archive"] = info.path;
		}
		return java;
	}

	function getJava( json, type, project ){
		var releases = deserializeJSON( arguments.json );
		for ( var r in releases ){
			if ( isStruct(r.binary)
					&&  r.binary.image_type == arguments.type
					&& r.binary.project == arguments.project ) {
				return r.binary.package.link;
			}
		}
		throw (message="#arguments.type# and #arguments.project# not found?", detail=arguments.json)
	}

	function logger( message ){
		systemOutput( arguments.message, true );
		arrayAppend( log, arguments.message );
	}

	function writeoutMarkdown( log ){
		if ( len( server.system.environment.GITHUB_STEP_SUMMARY ?: "" ) ){
			fileWrite( server.system.environment.GITHUB_STEP_SUMMARY, ArrayToList( arguments.log, chr( 10 ) ) );
		}
	}

	

</cfscript>