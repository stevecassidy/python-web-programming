#!/usr/bin/env bash
npm run build
rsync -avz .retype/ steve@stevecassidy.net:webapps/pwp
