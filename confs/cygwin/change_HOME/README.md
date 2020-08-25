## [Change your CYGWIN HOME Dierctory to point to WAMP](http://d3vit.com/changing-your-cygwin-home-directory-to-wamp/)
- Edit `cygwin.bat`
    <pre><code>@echo off

    SETLOCAL
    set HOME=C:\wamp\www
    C:
    chdir C:\cygwin\bin
    bash --login -i
    ENDLOCAL
    </code></pre>

- Add User
    <pre><code>mkpasswd -l -p “/cygdrive/c/wamp/www” > /etc/passwd</code></pre>

- Remove older user by any text editor from `c:\cygwin\etc`
