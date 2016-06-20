Feature: Test tasks for namespace 'apache'

	Background:
		Given a test app with the default configuration

	Scenario: copy only a local .htaccess file into web root (there is no other stage specific .htaccess file available)
		When I remove the file "config/etc/apache2/conf/dev.htaccess.erb"
		And I successfully run `cap dev apache:htaccess`
		Then a file named "htdocs/.htaccess" should exist
		And the file "htdocs/.htaccess" should contain exactly:
		"""
		<FilesMatch "index.php">
		Allow from all
		</FilesMatch>

		"""

	Scenario: copy a local .htaccess file into web root and merge it with dev.htacces
		When I successfully run `cap dev apache:htaccess`
		Then a file named "htdocs/.htaccess" should exist
		And the file "htdocs/.htaccess" should contain exactly:
		"""
		<FilesMatch "index.php">
		Allow from all
		</FilesMatch>
		<Files "favicon.ico">
		Deny from all
		</Files>
		"""

	Scenario: change web root and copy a local .htaccess file into it
		Given a directory named "web_root"
		When I extend the development capistrano configuration variable local_web_root_path with value 'web_root'
		And I successfully run `cap dev apache:htaccess`
		Then a file named "web_root/.htaccess" should exist
