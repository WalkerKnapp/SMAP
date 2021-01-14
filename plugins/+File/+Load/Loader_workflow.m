classdef Loader_workflow<interfaces.DialogProcessor
%     Loads SMAP workflows
    methods
        function obj=Loader_workflow(varargin)        
                obj@interfaces.DialogProcessor(varargin{:}) ;
                obj.inputParameters={'mainGui'};
        end
        
        function out=load(obj,p,file,mode)
            if nargin<4
                mode=getfilemode(file);
            end
            loadfile(obj,p,file,mode);
        end
        function pard=guidef(obj)
            pard=guidef;
        end
        function out=run(obj,p)
            [f,path]=uigetfile(obj.info.extensions);
            if exist([path f],'file')
                obj.load(p,[path f]);
                initGuiAfterLoad(obj);
                out.file=[f,path];
            else
                out.error='file not found. Cannot be loaded.';
            end
        end
        function clear(file,isadd)
        end
    end
end




function pard=guidef
info.name='workflow loader';
info.extensions={'*.mat';'*.*'};
info.dialogtitle='select workflow file';
pard.plugininfo=info;
pard.plugininfo.type='LoaderPlugin';
pard.plugininfo.description='Loads SMAP workflows';
end

function loadfile(obj,p,file,mode)            
switch mode
    case 'workflow'
        disp('workflow')
        [~,filename]=fileparts(file);
         module=interfaces.Workflow;
         module.processorgui=false;
         module.handle=figure('MenuBar','none','Toolbar','none','Name',filename);
        module.attachPar(obj.P);
        module.attachLocData(obj.locData);
        p.Vrim=10;
        p.Xrim=10;
        module.setGuiAppearence(p)
        module.makeGui;
        module.guihandles.showresults.Value=1;
        module.load(file);

    otherwise
        disp('file type not recognized')
end
end
        
 