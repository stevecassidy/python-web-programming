#!/usr/bin/env bash
gitbook build
rsync -avz _book/ stevecassidy@stevecassidy.net:webapps/pythonbook
