require_relative "contact_class"
require "csv"
require 'httparty'
require 'JSON'

module Main

  @@all_contacts = []

  def start
    puts <<-EOP
    ************************************************************
    //               Wynocde Contact Manager                  //
    ************************************************************

    EOP
    main_menu
  end

  def main_menu
    puts <<-EOP
                         #{weather_api}
                            MAIN MENU

                     What are we doing today?
                          (N)ew contact
                          (U)pdate contact
                          (S)how contact
                          (D)elete contact
                          (G)ithub Lookup
                      (I)mport your CSV file
                      (E)xport your contacts
                              (Q)uit


    EOP
    answer = gets.chomp.downcase

    case answer
      when "i"
        import_csv
      when "e"
        export_csv
      when "u"
        update
      when "d"
        delete
      when "n"
        create
      when "l"
        list
      when "q"
        exit
      when "s"
        show
      when "g"
        gitbub_api
      else
        puts "Sorry I did not understand that!"
        main_menu
    end
  end

  def weather_api
    api_key = '6caa0cf4dc9351c606b054d9e94cdb6f'
    response = HTTParty.get("http://api.openweathermap.org/data/2.5/weather?id=4155966&APPID=#{api_key}")
    body = JSON.parse response.body
    weather_description = body['weather'][0]['description']
    weather_temp = body['main']['temp']
    puts "\t    Today in Ft Lauderdale #{weather_description} at #{((weather_temp * 9/5) - 459.67).round}F."
  end

  def create
    puts "Ok, lets enter some information for your new contact!"
    sleep 1
    puts "Please enter your contacts name:"
      name = gets.chomp
    puts "Please enter what company your contact works for:"
      company = gets.chomp
    puts "Please enter the street address:"
      address = gets.chomp
    puts "Please enter the city"
      city = gets.chomp
    puts "Please enter the 2 letter state abbriviation:"
      state = state_validation
    puts "Please enter the zip code:"
      zipcode = zip_validation
    puts "Please enter the contacts e-mail:"
      email = email_validation
    puts "Please enter a mobile number for your contact:"
      mobile = mobile_validation
    puts "Please enter GitHub username"
      github_user = gets.chomp

    new_contact = Contact.new(name, company, address, city, state, zipcode, email, mobile, github_user)
    @@all_contacts << new_contact
    system ("clear")
    puts "Thank you! #{new_contact.name} was created successfully!"
    sleep 1
    main_menu
  end

  def update
    list
    puts "Enter the number of the contact to update."
    answer = validate_index
    contact = @@all_contacts[answer - 1]

    puts "You chose to update #{contact.name}."
    puts <<-EOP
    What would you like to update?
    (N)ame
    (C)ompany
    (A)ddress
    (C)ity
    (S)tate
    (Z)ipcode
    (E)mail
    (M)obile

    EOP
    answer = gets.chomp.downcase

    case answer
    when "n"
      puts "please enter a new name:"
      contact.name = gets.chomp
    when "c"
      puts "please enter a new company:"
      contact.company = gets.chomp
    when "a"
      puts "please enter a new street address:"
      contact.address = gets.chomp
    when "c"
      puts "please enter a new city:"
    when "s"
      puts "please enter a new state:"
        contact.state = state_validation
    when "z"
      puts "please enter a new zipcode"
      contact.zipcode = zip_validation
    when "e"
      puts "please enter a new e-mail:"
      contact.email = email_validation
    when "m"
      puts "please enter a new mobile number:"
      contact.mobile = mobile_validation
    else
      puts "I did not understand try again!"
      main_menu
    end
    main_menu
  end

  def show
    list
    puts "Enter the number of contact to show"
    answer = validate_index
    contact = @@all_contacts[answer - 1]
    puts "#{contact.name}"
    puts "#{contact.address}  #{contact.city}, #{contact.state} #{contact.zipcode}"
    puts "#{contact.email}"
    puts "#{contact.mobile}"
    main_menu
  end

  def delete
    list
    puts "Enter the number of the contact to delete."
    answer = validate_index
    c = answer - 1
    sleep 1
    system('clear')
    puts  "You have deleted your contact #{@@all_contacts[c].name}!"
    @@all_contacts.delete_at(c)
    main_menu
  end

  def list
    if @@all_contacts.empty?
      system("clear")
      puts "===========There are no contacts to in your address book==========="
      sleep 1
      main_menu
    else
      i = 1
      @@all_contacts.each do |contact|
        puts "#{i} - #{contact.name}"
        i += 1
      end
    end
  end

  def state_validation
    state = gets.chomp
    until state.length == 2
      puts "Please ensure you use the state 2 letter abbreviation!"
      state = gets.chomp
    end
    state
  end

  def zip_validation
    zipcode = gets.chomp.to_i
    until zipcode.to_s.length.between?(5,9)
      puts "Please ensure the zip code is between 5 and 9 digits!"
      zipcode = gets.chomp.to_i
    end
    zipcode
  end

  def email_validation
    email = gets.chomp
    until email.include?("@") && email.include?(".")
      puts "Not a valid email format, please try again"
      email = gets.chomp
    end
    email
  end

  def mobile_validation
    mobile = gets.chomp
    until mobile == mobile.to_i.to_s && mobile.size.between?(7,15)
      puts "Not a valid phone number format, please use between 7 and 15 numerical characters only."
      mobile = gets.chomp
    end
    mobile
  end

  def validate_index
    answer = gets.chomp.to_i
    while answer.zero? || answer > @@all_contacts.length
      puts "That is not a valid entry. Please try again"
      answer = gets.chomp.to_i
    end
    answer
  end

  def import_csv
    contacts = CSV.read('./contacts.csv')
    contact_count = 0
    contacts.each do |contact|
      if contact[0]
        name = contact[0]
        company = contact[1]
        address = contact[2]
        city = contact[3]
        state = contact[4]
        zipcode = contact[5]
        email = contact[6]
        mobile = contact[7]
        github_user = contact[8]
        @@all_contacts << Contact.new(name, company, address, city, state, zipcode, email, mobile, github_user)
      end
      contact_count += 1
    end
    puts "#{contact_count} imported!"
    main_menu
  end

  def export_csv
    CSV.open("myfile.csv", "w") do |csv|
    csv << ["name", "company", "address", "city", "state", "zipcode", "email", "mobile", "github"]
    Contact.all.each do |contact|
      a = contact.name, contact.company, contact.address, contact.city, contact.state, contact.zipcode, contact.email, contact.mobile, contact.github_user
      csv << a
      end
    end
    main_menu
  end

  def gitbub_api
    list
    puts "Enter the number of the contact."
    answer = validate_index
    user = @@all_contacts[answer - 1]
    user = user.github_user
    response = HTTParty.get("https://api.github.com/users/#{user}")
    body = JSON.parse response.body
    p body
    puts "My GitHub id is #{body['id']}"
    main_menu
  end
end

include Main
start
