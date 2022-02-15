function param_gui()

txt_file ='param.m';
temp_file='temp.m';
hh=[];

ss = get(0,'ScreenSize'); % get screen size
pos1 = [ss(3), ss(4),  900, 670] .* [ .1 .1   1  1];

figure('NumberTitle','off', 'OuterPosition', pos1, 'Toolbar','none', 'Menubar', 'none');

uicontrol('Style','pushbutton','String', 'Save',          'Position',[10,575, 50,30], 'HorizontalAlignment', 'left', 'Callback',@save_Callback);
uicontrol('Style','pushbutton','String', 'Load Defaults', 'Position',[65,575, 75,30], 'HorizontalAlignment', 'left', 'Callback',@defaults_Callback);

load_param(txt_file);

    function defaults_Callback(~,~)
        fileName= 'param_defaults.m';
        load_param_defaults(hh, fileName);
    end


    function load_param(txt_file)
        
        fid=fopen( txt_file,'r');
        
        count=0;
        paramNumber=0;
        hh=zeros(1,20);
        nn=0;
        
        while ~feof(fid)
            
            row=585-(20*count);
            
            line=fgets(fid);
            
            if contains(line, '%')
                uicontrol('Style','text','String', line,'Position',[150,row,600,20], 'HorizontalAlignment', 'left');
                
                if contains(line, 'p.')
                    paramNumber=paramNumber+1;
                    hh(paramNumber)=uicontrol('Style','edit', 'String', '0', 'Position',[20,row,100,20], 'HorizontalAlignment', 'left');
                end
            end
            
            count = count + 1;
            
            if contains(line, '=')
                jj=strfind(line, '=');
                kk=strfind(line, ';');
                val=line(jj+1:kk-1);
                nn=nn+1;
                set( hh(nn), 'String', val );
            end 
        end
        
        fclose(fid);
    end

    function save_Callback(~,~)
        
        ap1=txt_file;
        ap2=temp_file;
        % wd=pwd;
        % ap1=strcat(wd, '\', txt_file) % absolute path
        % ap2=strcat(wd, '\', temp_file)#
        
        fid_1=fopen(ap1,'r');
        fid_2=fopen(ap2,'w');
        
        nn=0;
        
        while ~feof(fid_1)
            
            line=fgetl(fid_1);
            
            if contains(line, '%')
                fprintf(fid_2,'%s\n',line);
            end
            
            if contains(line, '=')
                jj=strfind(line, '=');
                %kk=strfind(line, ';');
                %val=line(jj+1:kk-1);
                nn=nn+1;
                num=get( hh(nn), 'String' );
                line=sprintf('%s%s;\n', line(1:jj), num );
                
                fprintf(fid_2,'%s', line);
            end
        end
        fclose(fid_1);
        fclose(fid_2);
        
        movefile(ap2, ap1);
%         wd=pwd;
        
%         if success == 1
%             msg=sprintf('The parameters have been saved to the file %s.', ap1);
%             msgbox( msg );
%         else
%             msg=sprintf('Error: The parameters have NOT been saved to a file in the working directory %s.', wd);
%             msgbox(msg);
%         end
    end

    function load_param_defaults(hh, t_file)
        
        fid=fopen( t_file,'r');
        nn=0;
        
        while ~feof(fid)
            
            line=fgets(fid);

            if contains(line, '=')
                jj=strfind(line, '=');
                kk=strfind(line, ';');
                val=line(jj+1:kk-1);
                nn=nn+1;
                set( hh(nn), 'String', val );
            end
        end
        fclose(fid);
    end
end