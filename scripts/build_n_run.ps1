echo Building component...
$COMP_TAG = Read-Host -Prompt 'Input Docker tag name:'
docker build -rm -t $COMP_TAG ../

echo Running component...
Write-host "Would you like to use default data folder? (../data)" -ForegroundColor Yellow 
    $Readhost = Read-Host " ( y / n ) " 
    Switch ($ReadHost) 
     { 
       Y {Write-host "Yes use: " (join-path (Split-Path -Path (Get-Location).Path) "data"); $DATA_PATH = (join-path (Split-Path -Path (Get-Location).Path) "data") } 
       N {Write-Host "No, I'll specify myself"; $DATA_PATH = Read-Host -Prompt 'Input data folder path:'} 
       Default {Write-Host "Default, run app"; docker run -v $DATA_PATH`:/data -e KBC_DATADIR=/data $COMP_TAG} 
     } 

Write-host "Would you like to execute the container to Bash, skipping the execution?" -ForegroundColor Yellow 
    $Readhost = Read-Host " ( y / n ) " 
    Switch ($ReadHost) 
     { 
       Y {Write-host "Yes, get me to the bash"; docker run -ti -v $DATA_PATH`:/data --entrypoint=//bin//bash $COMP_TAG} 
       N {Write-Host "No, execute the app normally"; 
		    echo $DATA_PATH
			docker run -v $DATA_PATH`:/data -e KBC_DATADIR=/data $COMP_TAG
	   } 
       Default {Write-Host "Default, run app"; docker run -v $DATA_PATH`:/data -e KBC_DATADIR=/data $COMP_TAG} 
     } 


