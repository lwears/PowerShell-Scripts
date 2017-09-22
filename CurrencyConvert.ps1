## Powershell Currency Converter
##
##
##

$base_url = "http://api.fixer.io/latest"


function get_currency_rate ($currency, $base_currency)
    {
        #$query = $base_url + "?base={1}&symbols=$base_currency" % ($currency, $base_currency)
        $global:rates = Invoke-RestMethod -Uri $base_url
        $rate_in_currency = $rates["rates"][$base_currency]
        return $rate_in_currency
    }

function get_all_rates($base_currency)
    {
        $rates = Invoke-RestMethod -Uri ('{0}?base={1}' -f $base_url, $base_currency)
        ForEach-Object $currency, $rate in $rates.rates
            Write-Host("1 {2} = {1} {0}" -f $currency, $rate, $base_currency)
    }

function get_base_currency($currencies)    {
        $base_currency = ""
        do {$base_currency = Read-Host "Choose your base currency from $currencies"}
            while ($base_currency -contains $currencies)
        return $base_currency
    }


function main
    {
    #$available_currencies = $get_all_rates("USD")<
    [array]$values = "GBP", "USD", "NZD", "AUD", "SEK", "EUR"
    $base_currency = get_base_currency($values)
    # available_currencies = get_all_rates("USD")
    $convert_to = Read-Host "What currency do you want to convert to? $values "
    [int]$amount = Read-Host "How much would you like to convert to $convert_to ? "
    #$amount = int($amount)
    $rate = get_currency_rate -base_currency $base_currency -currency $convert_to
    $final_amount = $rate * $amount

    Write-Host("`r`n $amount, $base_currency converts to $final_amount, $convert_to `r`n")
    }

main