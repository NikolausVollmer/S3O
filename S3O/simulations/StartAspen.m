function Aspen = StartAspen()


Aspen = actxserver('Apwn.Document.37.0'); %35.0 = V9.0; 36.0 = V10.0; 37.0 = V11.0
[stat,mess] = fileattrib; % get attributes of folder (Necessary to establish the location of the simulation)

mydir  = pwd;
idcs   = strfind(mydir,'\');
newdir = mydir(1:idcs(end)-1);

mess.Name = append(newdir,'\models\evaporation_xylitol');
Simulation_Name = 'evaporation'; % Aspen Plus Simulation Name
Aspen.invoke('InitFromArchive2',[mess.Name '\' Simulation_Name '.bkp']);
Aspen.Visible = 1; % 1 = Aspen is Visible; 0 = Aspen is open but not visible
Aspen.SuppressDialogs = 1; % 1 = Suppress windows dialogs; 0 = allow windows dialogs;
end

