ShippingRates
=============

Steps to deploy the Shipping Rate:
1.	Install the dependent gems
a.	To Install the Active_Shipping gem, execute following command
```ruby
gem install active_shipping
```
b.	To Install the Active_Shipping gem, execute following command
```ruby
gem install fedex
```
c.	To Install the Ups_time_in_transit gem, execute following command
```ruby
gem install ups_time_in_transit
```
ups_time_in_transit.rb has been modified so copy the given ups_time_in_transit.rb file to install location e.g. ‘C:\RailsInstaller\Ruby1.9.3\lib\ruby\gems\1.9.1\gems\ups_time_in_transit-0.1.1\lib’ 
Note: Above path can be different based on the rails installation path.
2.	Use ShippingRates.rb to get the rates for Fedex and UPS

3.	Test and production credentials
Currently ShippingRates.rb using the Test environment credentials for Fedex and UPS as mentioned below:
```ruby
#Fedex Credentials
    Fedex_key = 'Uo5ehu0ZVJIkwN4y'
    Fedex_password = 'KXOH9K5coupax3FF4bM1opp9M'
    Fedex_account_number = '510087046'
    Fedex_meter = '118564789'
    Fedex_testmode = true  #for production set it as false
    
#UPS Credentials
    Ups_access_license_number = '9CA349F0CB25A9DB'
    Ups_user_id = 'piyushkp'
    Ups_password = 'Admin123#'
    Ups_testmode = true  #for production set it as false
```
For Production change the credentials for UPS and Fedex and set 
```ruby
    Ups_testmode = false
    Fedex_testmode = false  
```


Functions information:
1.	To get the Fedex and UPS rate information use following function
```ruby
def Shipping_Info (fromZipCode, toZipCode, weight)
```
Input parameters:

fromZipCode = source zipcode
toZipCode	= destination zipcode
weight	= package weight in LBS

Which return the array of Fedex and UPS rates 
```ruby
output = []                          
puts output = [fedex_rates, ups_rates]
```
2.	To get the Transit time for Fedex Ground Service use following function:
def getFedexTransitTime(fromZipCode, toZipCode, weight)
3.	To get the Transit time for UPS Ground  Service use following function:
```ruby
def getUPSTransitTime(fromZipCode, toZipCode, weight)
```
4.	To get the state for given postcode for USA use following function:
```ruby
def state_from_zip(zip)
```

Sample Code to call the Function:
Use following code to call the Shipping_Info function:
```ruby
my_object = ShippingRates::ShippingInfo.new
results = my_object.Shipping_Info "90210", "48503", 10
```

Where 
ShippingRates = Module name
ShippingInfo = class name
