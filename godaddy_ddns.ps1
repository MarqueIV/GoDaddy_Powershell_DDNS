<#
This script is used to check and update your GoDaddy DNS server to the IP address of your current internet connection.
First go to GoDaddy developer site to create a developer account and get your key and secret
https://developer.godaddy.com/getstarted
 
Pass in the first 4 varriables as command-line arguments, or hard-code them here if you prefer

e.g. '.\godaddy_ddns.ps1 keykeykey secretsecretsecret MarkDonohoe.com home'
#>

$key    = $args[0] # key for godaddy developer API
$secret = $args[1] # Secret for godday developer API
$domain = $args[2] # Your domain
$name   = $args[3] # #name of the A record to update

$endpoint                 = 'https://api.godaddy.com/v1/domains/' + $domain + '/records/A/' + $name
$headers                  = @{}
$headers["Authorization"] = 'sso-key ' + $key + ':' + $secret
$result                   = Invoke-WebRequest $endpoint -method get -headers $headers -UseBasicParsing
$content                  = ConvertFrom-Json $result.content
$dnsIp                    = $content.data

# Get public ip address there are several websites that can do this.
# Note: 'ExpandProperty' extracts the property value from the key/value pair that Select-Object returns
$currentIp = Invoke-RestMethod http://ipinfo.io/json | Select-Object -ExpandProperty ip

if ( $currentIp -ne $dnsIp) {

    $Request = @(@{ ttl=600; data=$currentIp; })
    $JSON = Convertto-Json $request

    Invoke-WebRequest $endpoint -method put -headers $headers -Body $json -ContentType "application/json" -UseBasicParsing
}

