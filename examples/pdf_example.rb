$LOAD_PATH << File.expand_path(File.join(File.dirname(__FILE__),'..','lib'))

require 'rubygems'
require 'ruby-nessus'
require 'prawn'
require 'prawn/layout'

@pdf = Prawn::Document.new

Nessus::XML.new("example.nessus") do |scan|

  @pdf.font_size = 9

  @pdf.bounding_box [0,@pdf.cursor], :width => 490 do

    @pdf.move_down(10)

    @pdf.text("#{scan.title.split(' - ')[1]}", :size => 20)

    @pdf.move_down 10

    @pdf.text("Policy: #{scan.policy_name}")
    @pdf.text("Policy Description: #{scan.policy_name}")
    @pdf.text("Start Time: #{scan.start_time}")
    @pdf.text("Stop Time: #{scan.stop_time}")
    @pdf.text("Runtime: #{scan.runtime}")

    @pdf.move_down 10

    @pdf.stroke do
      @pdf.line @pdf.bounds.top_left,    @pdf.bounds.top_right
      @pdf.line @pdf.bounds.bottom_left, @pdf.bounds.bottom_right
    end

  end

  @pdf.move_down(20)

  data = [["#{scan.host_count}", "#{scan.low_severity_count}", "#{scan.medium_severity_count}", "#{scan.high_severity_count}", "#{scan.open_ports_count}", "#{scan.total_event_count}"]]

  @pdf.table data,
  :position => :left,
  :border_style => :grid,
  :headers => ['Host Count', 'Low Severity Events', 'Medium Severity Events', 'High Severity Events', 'Open Ports', 'Total Event Count'],
  :align => :left,
  :font_size => 9,
  :row_colors => :pdf_writer,
  :align_headers => :left

  @pdf.move_down(10)

  scan.hosts do |host|
    
    @pdf.bounding_box [0,@pdf.cursor], :width => 490 do
      @pdf.move_down(20)
      @pdf.text("#{host.hostname}", :size => 18)
      @pdf.text("Scan Time: #{host.scan_run_time}")
      @pdf.text("Low: #{host.low_severity_events} Medium: #{host.medium_severity_events} High: #{host.high_severity_events} Total: #{host.event_count}")
      @pdf.move_down 10
      @pdf.stroke do
        @pdf.line @pdf.bounds.bottom_left, @pdf.bounds.bottom_right
      end
    end
    @pdf.move_down(10)

    @i = 0
    host.events do |event|
      
      next if event.severity.to_i <= 1
      @pdf.text("#{@i+=1}. #{event.name}", :size => 11)
      @pdf.text("Port: #{event.severity.in_words}")
      @pdf.text("Port: #{event.port}")
      @pdf.move_down(10)
    end

  end
end

puts "PDF Created Successfully!"

@pdf.render_file('ruby-nessus-example.pdf')