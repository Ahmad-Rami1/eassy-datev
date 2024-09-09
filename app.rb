require 'sinatra'
require 'json'
require 'datev'
require 'fileutils'
require 'logger'
# POST route for export bookings

logger = Logger.new('error.log')

post '/export/bookings' do
  begin
    # Parse the JSON data from the request body
    data = JSON.parse(request.body.read)

    # Extract the header and bookings data
    header = data['header']
    bookings = data['bookings']

    # Initialize the Datev::BookingExport object with the header information
    export = Datev::BookingExport.new(
      'Herkunft'        => header['Herkunft'],
      'Exportiert von'  => header['Exportiert von'],
      'Berater'         => header['Berater'],
      'Mandant'         => header['Mandant'],
      'WJ-Beginn'       => Date.parse(header['WJ-Beginn']),
      'Datum vom'       => Date.parse(header['Datum vom']),
      'Datum bis'       => Date.parse(header['Datum bis']),
      'Bezeichnung'     => header['Bezeichnung']
    )

    # Add each booking to the export
    bookings.each do |booking|
      export << {
        'Belegdatum'                     => Date.parse(booking['Belegdatum']),
        'Buchungstext'                   => booking['Buchungstext'],
        'Umsatz (ohne Soll/Haben-Kz)'    => booking['Umsatz (ohne Soll/Haben-Kz)'],
        'Soll/Haben-Kennzeichen'         => booking['Soll/Haben-Kennzeichen'],
        'Konto'                          => booking['Konto'],
        'Gegenkonto (ohne BU-Schlüssel)' => booking['Gegenkonto (ohne BU-Schlüssel)'],
        'BU-Schlüssel'                   => booking['BU-Schlüssel'],
        'Belegfeld 1'                    => booking['Belegfeld 1'],
        'Belegfeld 2'                    => booking['Belegfeld 2']
      }
    end

    # Define the file path
    file_path = 'EXTF_Buchungsstapel.csv'

    # Generate the CSV file content and save to disk
    export.to_file(file_path)

    # Read the generated file content
    file_content = File.read(file_path)

    # Set the correct content type and disposition for file download
    content_type 'text/csv'
    attachment file_path

    # Stream the file content as the response
    response = file_content

    # Delete the file after sending it
    File.delete(file_path)

    # Return the response
    response

  rescue => e
    # Log the error
    puts "Error occurred: #{e.message}"
    puts e.backtrace.join("\n")

    logger.error("Error occurred: #{e.message}")
    logger.error(e.backtrace.join("\n"))

    # Handle errors
    status 500
    content_type :json
    { error: "Failed to generate export: #{e.message}" }.to_json
  end
end


post '/export/contacts' do
  begin
    # Parse the JSON data from the request body
    data = JSON.parse(request.body.read)

    # Extract the header and contacts data
    header = data['header']
    contacts = data['contacts']

    # Initialize the Datev::BookingExport object with the header information
    export = Datev::ContactExport.new(
      'Herkunft'        => header['Herkunft'],
      'Exportiert von'  => header['Exportiert von'],
      'Berater'         => header['Berater'],
      'Mandant'         => header['Mandant'],
      'WJ-Beginn'       => Date.parse(header['WJ-Beginn']),
      'Datum vom'       => Date.parse(header['Datum vom']),
      'Datum bis'       => Date.parse(header['Datum bis']),
      'Bezeichnung'     => header['Bezeichnung']
    )

    # Add each contact to the export
    contacts.each do |contact|
      export << {
        "Konto"                       => contact["Konto"],
        "Name (Adressatentyp keine Angabe)" => contact["Name (Adressatentyp keine Angabe)"],
        "Adressatentyp"                 => contact["Adressatentyp"],
        "Kurzbezeichnung"             => contact["Kurzbezeichnung"],
        "EU-Land"                     => contact["EU-Land"],
        "EU-USt-IdNr."                    => contact["EU-USt-IdNr."],
        "Adressart"                   => contact["Adressart"],
        "Straße"                      => contact["Straße"],
        "Postleitzahl"                => contact["Postleitzahl"],
        "Ort"                         => contact["Ort"],
        "Adresszusatz"                => contact["Adresszusatz"],
        "Kennz. Korrespondenzadresse" => contact["Kennz. Korrespondenzadresse"],
        "E-Mail"                      => contact["E-Mail"]
      }
    end

    # Generate the CSV file content as a string
    # Define the file path
    file_path = 'EXTF_Stammdaten.csv'

    # Generate the CSV file content and save to disk
    export.to_file(file_path)

    # Read the generated file content
    file_content = File.read(file_path)

    # Set the correct content type and disposition for file download
    content_type 'text/csv'
    attachment file_path

    # Stream the file content as the response
    response = file_content

    # Delete the file after sending it
    File.delete(file_path)

    # Return the response
    response

  rescue => e
    # Log the error
    puts "Error occurred: #{e.message}"
    puts e.backtrace.join("\n")

    logger.error("Error occurred: #{e.message}")
    logger.error(e.backtrace.join("\n"))

    # Handle errors
    status 500
    content_type :json
    { error: "Failed to generate export: #{e.message}" }.to_json
end
end



# Bind Sinatra to all network interfaces
set :bind, '0.0.0.0'
