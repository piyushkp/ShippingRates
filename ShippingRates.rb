require 'active_shipping'
require 'fedex'
require 'ups_time_in_transit'

include ActiveMerchant::Shipping

module ShippingRates  

class ShippingInfo

def initialize ()
  
 #Origin zipcode
    @FROM_ZIP_CODE = 90210
    
 #Fedex Credentials
    @FEDEX_KEY = 'Uo5ehu0ZVJIkwN4y'
    @FEDEX_PASSWORD = 'KXOH9K5coupax3FF4bM1opp9M'
    @FEDEX_ACCOUNT_NUMBER = '510087046'
    @FEDEX_METER = '118564789'
    @FEDEX_TESTMODE = true  #for production set it as false
    
 #UPS Credentials
    @UPS_ACCESS_LICENSE_NUMBER = '9CA349F0CB25A9DB'
    @UPS_USER_ID = 'piyushkp'
    @UPS_PASSWORD = 'Admin123#'
    @UPS_TESTMODE = true  #for production set it as false
    
end 
 
  #This function return the rates and deliverytimes for Fedex and UPS for given fromZipcode, toZipCode, and package weight
  def shipping_info (to_zip_code, weight)
    
    initialize();
    
    #Shipment Info Start
    
    packages = [ Package.new( weight * 16,                        # weight in ounce = LB *16
                              [10,5,4],                           # in Inches 
                              :units => :imperial)         
               ]

    origin = Location.new( :country => 'US',
                           :zip => @FROM_ZIP_CODE)

    destination = Location.new( :country => 'US',
                                :zip => to_zip_code)
    #Shipment Info End
    
    # Fedex Info Start
    
    fedex = FedEx.new(:key => @FEDEX_KEY,
                      :password => @FEDEX_PASSWORD,
                      :account => @FEDEX_ACCOUNT_NUMBER,
                      :login => @FEDEX_METER,
                      :test => @FEDEX_TESTMODE
                      )
    fedex_rates = {}
    
    begin                          

    fedex_response = fedex.find_rates(origin, destination, packages)

    #fedex_transit_time =  get_fedex_transit_time(@FROM_ZIP_CODE, to_zip_code, weight)

    fedex_rates =  fedex_response.rates.sort_by(&:price).collect {|rate| rate.delivery_date == nil ? ["Carrier" => rate.carrier, "Code" => rate.service_name, "Price" => rate.price.to_f/100, "Transit Time" => get_fedex_transit_time(@FROM_ZIP_CODE, to_zip_code, weight)] : ["Carrier" => rate.carrier, "Code" => rate.service_name, "Price" => rate.price.to_f/100, "Delivery On" => rate.delivery_date]} 

    rescue Exception => e
      if (e.message == 'ERROR - 0105: General Error')
        puts 'Fedex Service is temporary not available'
      end
    end
    # Fedex Info End
    
    #UPS Info Start
      
    ups_rates = {}
    
    begin
      
    ups = ActiveMerchant::Shipping::UPS.new(:login => @UPS_USER_ID, :password => @UPS_PASSWORD, :key => @UPS_ACCESS_LICENSE_NUMBER, :test => @UPS_TESTMODE)
    
    response = ups.find_rates(origin, destination, packages)
    
    #ups_ground_transit_time  = get_ups_ground_transit_time(from_zip_code, to_zip_code, weight)
    
    ups_rates = response.rates.collect {|rate| rate.delivery_date == nil ? ["Carrier" => rate.carrier, "Code" => rate.service_name, "Price" => rate.price.to_f/100, "Transit Time" => get_ups_ground_transit_time(@FROM_ZIP_CODE, to_zip_code, weight) ] : ["Carrier" => rate.carrier, "Code" => rate.service_name, "Price" => rate.price.to_f/100, "Delivery On" => rate.delivery_date]}
    
    rescue Exception => e
      puts e.message
    end
    
    #UPS Info End
    
    #USPS Start
    
    #USPS End
    
    #OUTPUT
    
    output = []
                          
    puts output = [fedex_rates, ups_rates]
    

  end

  #This function return the Fedex transit time for GROUND service.
  def get_fedex_transit_time(from_zip_code, to_zip_code, weight)
    
    fedex_ship = Fedex::Shipment.new(   :key => @FEDEX_KEY,
                                        :password => @FEDEX_PASSWORD,
                                        :account_number => @FEDEX_ACCOUNT_NUMBER,
                                        :meter => @FEDEX_METER,
                                        :mode => @FEDEX_TESTMODE
                                    )
 
    shipping_details = { :packaging_type => "YOUR_PACKAGING",
                         :drop_off_type => "REGULAR_PICKUP"
                       }
                       
    pkg = []
    pkg << { :weight => {:units => "LB", :value => weight},
             :dimensions => {:length => 10, :width => 5, :height => 4, :units => "IN" }
           }
                       
   shipper = {  :name => "Sender",
                :company => "Catprint",
                :phone_number => "555-555-5555",
                :address => "None",
                :city => "None",
                :state => state_from_zip("#{from_zip_code}"),
                :postal_code => "#{from_zip_code}",
                :country_code => "US" 
              }
            
    recipient = { :name => "Recipient",
                  :company => "Company",
                  :phone_number => "555-555-5555",
                  :address => "Main Street",
                  :city => "None",
                  :state => state_from_zip("#{to_zip_code}"),
                  :postal_code => "#{to_zip_code}",
                  :country_code => "US",
                  :residential => "false" 
                }
                
    fedex_transit_day = fedex_ship.ship(:shipper=>shipper,
                                        :recipient => recipient,
                                        :packages => pkg,
                                        :service_type => "FEDEX_GROUND",
                                        :shipping_details => shipping_details
                                        )
    
    #return fedex_transit_day[:completed_shipment_detail][:operational_detail] [:transit_time]
    
    return convert_transit_days_to_number(fedex_transit_day[:completed_shipment_detail][:operational_detail] [:transit_time])
    
  end
  
  #This function return the UPS transit time for GROUND service.
  def get_ups_ground_transit_time(from_zip_code, to_zip_code, weight)
    
    access_options = {
                        :access_license_number => @UPS_ACCESS_LICENSE_NUMBER,
                        :user_id => @UPS_USER_ID,
                        :password => @UPS_PASSWORD,
                        :order_cutoff_time => 17 ,
                        :sender_state => state_from_zip("#{from_zip_code}"),
                        :sender_country_code => 'US',
                        :sender_zip => "#{from_zip_code}"
                      }
                      
    request_options = {
                        :total_packages => 1,
                        :unit_of_measurement => 'LBS',
                        :weight => weight,
                        :state => state_from_zip("#{to_zip_code}"),
                        :zip => "#{to_zip_code}",
                        :country_code => 'US',
                        :mode => @UPS_TESTMODE
                      }
                        
    return Integer(UPS::TimeInTransit.new(access_options).request(request_options))   
   
  end
  
  #This function return the state from given zipcode for USA
  def state_from_zip(zip)
      zip = zip.to_i
      {
        (99500...99929) => "AK", 
        (35000...36999) => "AL", 
        (71600...72999) => "AR", 
        (75502...75505) => "AR", 
        (85000...86599) => "AZ", 
        (90000...96199) => "CA", 
        (80000...81699) => "CO", 
        (6000...6999) => "CT", 
        (20000...20099) => "DC", 
        (20200...20599) => "DC", 
        (19700...19999) => "DE", 
        (32000...33999) => "FL", 
        (34100...34999) => "FL", 
        (30000...31999) => "GA", 
        (96700...96798) => "HI", 
        (96800...96899) => "HI", 
        (50000...52999) => "IA", 
        (83200...83899) => "ID", 
        (60000...62999) => "IL", 
        (46000...47999) => "IN", 
        (66000...67999) => "KS", 
        (40000...42799) => "KY", 
        (45275...45275) => "KY", 
        (70000...71499) => "LA", 
        (71749...71749) => "LA", 
        (1000...2799) => "MA", 
        (20331...20331) => "MD", 
        (20600...21999) => "MD", 
        (3801...3801) => "ME", 
        (3804...3804) => "ME", 
        (3900...4999) => "ME", 
        (48000...49999) => "MI", 
        (55000...56799) => "MN", 
        (63000...65899) => "MO", 
        (38600...39799) => "MS", 
        (59000...59999) => "MT", 
        (27000...28999) => "NC", 
        (58000...58899) => "ND", 
        (68000...69399) => "NE", 
        (3000...3803) => "NH", 
        (3809...3899) => "NH", 
        (7000...8999) => "NJ", 
        (87000...88499) => "NM", 
        (89000...89899) => "NV", 
        (400...599) => "NY", 
        (6390...6390) => "NY", 
        (9000...14999) => "NY", 
        (43000...45999) => "OH", 
        (73000...73199) => "OK", 
        (73400...74999) => "OK", 
        (97000...97999) => "OR", 
        (15000...19699) => "PA", 
        (2800...2999) => "RI", 
        (6379...6379) => "RI", 
        (29000...29999) => "SC", 
        (57000...57799) => "SD", 
        (37000...38599) => "TN", 
        (72395...72395) => "TN", 
        (73300...73399) => "TX", 
        (73949...73949) => "TX", 
        (75000...79999) => "TX", 
        (88501...88599) => "TX", 
        (84000...84799) => "UT", 
        (20105...20199) => "VA", 
        (20301...20301) => "VA", 
        (20370...20370) => "VA", 
        (22000...24699) => "VA", 
        (5000...5999) => "VT", 
        (98000...99499) => "WA", 
        (49936...49936) => "WI", 
        (53000...54999) => "WI", 
        (24700...26899) => "WV", 
        (82000...83199) => "WY"
        }.each do |range, state|
          return state if range.include? zip
        end

        raise ShippingError, "Invalid zip code"
      end
  
  def convert_transit_days_to_number (days)          
      days = days.to_str
      {
        ('ELEVEN_DAYS')   => 11,
        ('FIFTEEN_DAYS')  => 15,
        ('FIVE_DAYS')     => 5,
        ('FOURTEEN_DAYS') => 14,
        ('FOUR_DAYS')     => 4,
        ('NINETEEN_DAYS') => 19,
        ('NINE_DAYS')     => 9,
        ('ONE_DAY')       => 1,
        ('SEVENTEEN_DAYS')=> 17,
        ('SEVEN_DAYS')    => 7,
        ('SIXTEEN_DAYS')  => 16,
        ('SIX_DAYS')      => 6,
        ('TEN_DAYS')      => 10,
        ('THIRTEEN_DAYS') => 13,
        ('THREE_DAYS')    => 3,
        ('TWELVE_DAYS')   => 12,
        ('TWENTY_DAYS')   => 20,
        ('TWO_DAYS')      => 2,
        ('EIGHTEEN_DAYS') => 18,
        ('EIGHT_DAYS')    => 8
       }.each do |day, number|
          return number if day.include? days
        end
        
        raise ShippingError, "Invalid transit time"
  end
  
end

end

#sample code to call the function

my_object = ShippingRates::ShippingInfo.new
results = my_object.shipping_info "48503", 10



