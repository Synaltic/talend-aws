#!/bin/sh

# these two attributes are replaced at runtime
bucketName="repository.#replace_env#"
region="#replace_region#"

plistFileName="rewritevitrine.txt"
plistFile="/var/www/${plistFileName}"
plistFileS3="conf/vitrines-dns/${plistFileName}"
plistHashFile="/var/www/${plistFileName}.etag"

s3Etag=$(aws s3api head-object --bucket ${bucketName} --key ${plistFileS3} --region ${region} | jq .ETag -r | sed 's/"//g')

if [ -s ${plistHashFile} ] && [ ${s3Etag} == `cat ${plistHashFile}` ]
then
    echo "File ${plistFile} exists and up-to-date."
else
    echo "File ${plistFile} doesn't exists or is not up-to-date."
    aws s3 cp s3://${bucketName}/${plistFileS3} ${plistFile}.tmp --region ${region}
    echo ${s3Etag} > ${plistHashFile}
    mv ${plistFile}.tmp ${plistFile}
fi

