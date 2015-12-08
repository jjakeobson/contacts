class Contact
  attr_accessor :name, :company, :address, :city, :state, :zipcode, :email, :mobile, :github_user


  def initialize(name, company, address, city, state, zipcode, email, mobile, github_user)
    @name = name
    @company = company
    @address = address
    @city = city
    @state = state
    @zipcode = zipcode
    @email = email
    @mobile = mobile
    @github_user = github_user

  end
end
