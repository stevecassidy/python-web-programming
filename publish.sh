#!/usr/bin/env bash
npm run build
rsync -avz _book/ steve@stevecassidy.net:webapps/pwp
