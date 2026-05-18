<cfscript>
	/*
		always force mod_cfml to trigger (1.10 still triggers on read path_info, rather than the resolved filename)
		https://luceeserver.atlassian.net/browse/LDEV-3554
		https://github.com/viviotech/mod_cfml/issues/37
	*/
	if ( listLast( cgi.request_url, "/" ) neq "index.cfm" )
		location url="/index.cfm" addtoken="false";

	luceeMajor = listGetAt( server.lucee.version, 1, "." );
	luceeMajorMinor = luceeMajor & "." & listGetAt( server.lucee.version, 2, "." );

	// Prefer a major.minor specific "What's new" page, fall back to the major.
	switch ( luceeMajorMinor ) {
		case "7.1": newURL = "https://docs.lucee.org/guides/lucee-7-1.html"; break;
		case "6.2": newURL = "https://docs.lucee.org/guides/lucee-6.2.html"; break;
		default:    newURL = "https://docs.lucee.org/guides/lucee-" & luceeMajor & ".html";
	}

	adminURL       = "#CGI.CONTEXT_PATH#/lucee/admin.cfm";
	webAdminURL    = "#CGI.CONTEXT_PATH#/lucee/admin/web.cfm";
	serverAdminURL = "#CGI.CONTEXT_PATH#/lucee/admin/server.cfm";
</cfscript><!DOCTYPE html>
<html>
<head>
	<title><cfoutput>Lucee #luceeMajorMinor#</cfoutput></title>
	<meta name="robots" content="noindex, nofollow">
	<link rel="stylesheet" type="text/css" href="https://fonts.googleapis.com/css?family=Open+Sans:400,300,600,700,800">
	<link rel="stylesheet" type="text/css" href="/assets/css/main.css">
</head>
<body>
<cfoutput>

<section class="page-banner">
	<img src="/assets/img/lucee-logo.png" alt="Lucee">
	<h1>Welcome to your Lucee #luceeMajorMinor# Installation!</h1>
	<p class="lead-text">You are now successfully running Lucee #server.lucee.version# on your system!</p>
</section>

<section id="wrong-mapping-warning" class="wrong-mapping-warning" style="text-align: center; font-weight: bolder; color: red; border: red 2px solid; margin:15px; padding: 5px;">
	<p>Warning, if you can see this message, your webserver webroot is not mapped to the Lucee webroot.</p>
	<p>This means Lucee is only configured to handle .cfm and .cfc and other files like css, js and images won't load properly.</p>
</section>

<section id="contents">
	<div class="main-content">
		<ul class="listing">
			<li class="listing-item">
				<div class="listing-thumb">
					<a href="#newURL#"><img src="/assets/img/img-new.png" alt=""></a>
				</div>
				<div class="listing-content">
					<h2 class="title"><a href="#newURL#">New in Lucee #luceeMajorMinor#</a></h2>
					<p>
						<cfswitch expression="#luceeMajorMinor#">
							<cfcase value="7.1">
								Lucee 7.1 builds on the <a href="https://docs.lucee.org/recipes/single-vs-multi-mode.html">single context</a> architecture introduced in 7.0 and moves some core functionality out into separate extensions, keeping the core leaner. <a href="#newURL#">New features overview</a>
							</cfcase>
							<cfdefaultcase>
								<cfswitch expression="#luceeMajor#">
									<cfcase value="5">
										Lucee 5 is the first major release of Lucee after forking from the Railo project. Lucee 5 is not about dazzling new features but about improving the core language and providing a complete architectural overhaul of the engine which brings Lucee and CFML as a language to a whole new level of awesome! <a href="#newURL#">New features overview</a>
									</cfcase>
									<cfcase value="6">
										Lucee 6 introduces a number of key changes
										<ul>
											<li>Server Configuration now uses json rather than xml</li>
											<li>A new <a href="https://docs.lucee.org/recipes/single-vs-multi-mode.html">single mode</a>, rather than having both a server and web context(s)</li>
										</ul>
										<a href="#newURL#">New features overview</a>
									</cfcase>
									<cfcase value="7">
										Lucee 7 introduces a <a href="https://docs.lucee.org/recipes/single-vs-multi-mode.html">single context</a> architecture, replacing the previous server/web context model with one unified configuration. <a href="#newURL#">New features overview</a>
									</cfcase>
								</cfswitch>
							</cfdefaultcase>
						</cfswitch>
					</p>
				</div>
			</li>

			<li class="listing-item">
				<div class="listing-thumb">
					<a href="https://opencollective.com/lucee"><img src="/assets/img/img-lightning.png" alt=""></a>
				</div>
				<div class="listing-content">
					<h2 class="title"><a href="https://opencollective.com/lucee">Support Lucee</a></h2>
					<p>Lucee is free and open source, funded by sponsors and the <a href="https://www.lucee.org">Lucee Association Switzerland</a>. If your business runs on Lucee, please <a href="https://opencollective.com/lucee">support its development on Open Collective</a>.</p>
				</div>
			</li>

			<li class="listing-item">
				<div class="listing-thumb">
					<a href="https://docs.lucee.org/guides/getting-started/first-steps.html"><img src="/assets/img/img-first-steps.png" alt=""></a>
				</div>
				<div class="listing-content">
					<h2 class="title"><a href="https://docs.lucee.org/guides/getting-started/first-steps.html">First steps</a></h2>
					<p>If you are new to Lucee or the CFML language in general, check our <a href="https://docs.lucee.org/guides/getting-started/first-steps.html">First Steps</a> page in our docs. There you'll find a quick primer of the amazing and easy-to-learn <a href="https://docs.lucee.org/categories/core.html">CFML language</a>. If you come from a design-based background, CFML's tag-based language should make it easy to learn and use right away. If you're coming from another development language, the CFML script-based syntax may be more to your liking. Either way, it's a great place to get started on your journey with Lucee and CFML!</p>
					<p>Also check our <a href="https://docs.lucee.org/recipes/recommended-settings.html">Recommended Settings</a> for tuning your Lucee installation, and the <a href="https://docs.lucee.org/recipes/troubleshooting.html">Troubleshooting</a> guide if things aren't working as expected.</p>
				</div>
			</li>

			<li class="listing-item">
				<div class="listing-thumb">
					<a href="https://docs.lucee.org/"><img src="/assets/img/img-code.png" alt=""></a>
				</div>
				<div class="listing-content">
					<h2 class="title"><a href="https://docs.lucee.org/">Documentation</a></h2>
					<p>The <a href="https://docs.lucee.org/">Lucee docs</a> cover everything from <a href="https://docs.lucee.org/recipes.html">recipes</a> and the <a href="https://docs.lucee.org/reference.html">code reference</a> to <a href="https://docs.lucee.org/categories/devops.html">DevOps guides</a> for running Lucee in production.</p>
				</div>
			</li>

			<li class="listing-item">
				<div class="listing-thumb">
					<a href="#adminURL#"><img src="/assets/img/img-exclamation-mark.png" alt=""></a>
				</div>
				<div class="listing-content">
					<h2 class="title"><a href="#adminURL#"><cfif luceeMajor lt 7>Secure Administrators<cfelse>Secure Administrator</cfif></a></h2>
					<cfif luceeMajor lt 7>
						<p>Important! For production servers, we recommend <strong>disabling the Admin entirely</strong>. If you need it enabled, secure the <a href="#serverAdminURL#">Server</a> and <a href="#webAdminURL#">Web</a> admins of every context with strong <a href="https://docs.lucee.org/recipes/admin-password.html">passwords</a> and other access restrictions.</p>
					<cfelse>
						<p>Important! For production servers, we recommend <strong>disabling the Admin entirely</strong>. If you need it enabled, secure the <a href="#serverAdminURL#">Admin</a> with a strong <a href="https://docs.lucee.org/recipes/admin-password.html">password</a> and other access restrictions.</p>
					</cfif>
				</div>
			</li>
		</ul>
	</div>

	<aside class="sidebar">
		<div class="sidebar-wrap">
			<div class="widget">
				<h3 class="widget-title">Related Websites</h3>

				<p class="file-link"><a href="https://www.lucee.org">Lucee Association Switzerland</a></p>
				<p>Non-profit custodians and maintainers of the Lucee Project</p>

				<p class="file-link"><a href="https://www.lucee.org/aboutlucee/community.html">Get Involved</a></p>
				<p>Get involved in the Lucee Project!</p>
				<ul class="involved-list">
					<li>Engage with other Lucee community members via our <a href="https://dev.lucee.org/">Developer forum</a></li>
					<li><a href="https://luceeserver.atlassian.net/jira">Submit bugs and feature requests</a></li>
					<li><a href="https://github.com/lucee/Lucee">Contribute to the code</a></li>
					<li>Become a <a href="https://www.lucee.org/aboutlucee/community.html">Lucee Supporter</a></li>
				</ul>

				<p class="file-link"><a href="https://lucee.org/support.html">Professional Services</a></p>
				<p>Whether you need installation support or other professional services, browse our <a href="https://lucee.org/support.html">directory of providers</a>.</p>
			</div>
		</div>
	</aside>
</section>

<footer id="subhead">
	<a href="/" class="footer-logo">
		<img src="/assets/img/lucee-logo.png" alt="Lucee">
	</a>
</footer>

</cfoutput>
</body>
</html>
