@echo off
set profile-user=climax
set stack-name=aws-ses
set project-tags=aws-ses
set aws-region=eu-west-1
set code-bucket=aws-ses-code
set domain-name=aldunate.pro
set hash-string-for-naming=5b5ae195cd656d2308e178ea

@echo ..
@echo ..
@echo ..
@echo Variables:
@echo profile user  = %profile-user%
@echo stack name    = %stack-name%
@echo project tags  = %project-tags%
@echo aws-region    = %aws-region%
@echo code-bucket    = %code-bucket%
@echo domain-name    = %domain-name%
@echo hash-string-for-naming    = %hash-string-for-naming%


@echo ..
@echo ..
@echo ..
@echo verifying yaml template ...
CALL aws cloudformation validate-template ^
         --region %aws-region% ^
         --profile %profile-user% ^
         --template-body file://aws-ses-infrastructure.yaml

@echo ..
@echo ..
@echo ..
@echo cloudformation package ...
CALL aws cloudformation package ^
    --region %aws-region% ^
    --profile %profile-user% ^
    --template-file aws-ses-infrastructure.yaml ^
    --output-template-file aws-ses-infrastructure-new.yaml ^
    --s3-bucket %code-bucket% ^
    --profile %profile-user%

@echo ..
@echo ..
@echo ..
@echo cloudformation deploy ...
CALL aws cloudformation deploy ^
     --region %aws-region% ^
     --template-file aws-ses-infrastructure-new.yaml ^
     --stack-name %stack-name% ^
     --capabilities CAPABILITY_IAM ^
     --profile %profile-user% ^
     --tags Project=%project-tags% ^
     --parameter-overrides TagProjectParameter=%project-tags%, ^
                           DomainName=%domain-name%, ^
                           HashStringForNaming=%hash-string-for-naming%

@echo ..
@echo ..
@echo ..
@echo -
@echo finished!
