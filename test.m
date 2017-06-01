try
    [objects,imgTable] = SearchSystem(objects); % Used to time the system using Run and Time
catch err
    send_text_message('518-330-0344','att','error was recieved');
    disp(err)
end
send_text_message('518-330-0344','att','finished');