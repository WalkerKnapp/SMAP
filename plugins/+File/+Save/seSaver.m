classdef seSaver<interfaces.DialogProcessor
    methods
        function obj=seSaver(varargin)  
                obj@interfaces.DialogProcessor(varargin{:}) ;
                obj.inputParameters={'filelist_long','mainfile','mainGui','numberOfLayers','sr_layerson','sr_pixrec','layers','sr_image','sr_pos','group_dt','group_dx'};
        end
        
        function out=save(obj,p)
            obj.status('save SE file')
            lastSMLFile = obj.getPar('lastSMLFile');
            defaultFn = replace(lastSMLFile, '_sml', '_se');
            fibrilStatistics = getFieldAsVector(obj.locData.SE.sites,'evaluation.fibrilStatistics');
            fibrilDynamics = getFieldAsVector(obj.locData.SE.sites,'evaluation.fibrilDynamics');
            fibrilStraightener = getFieldAsVector(obj.locData.SE.sites,'evaluation.fibrilStraightener');
            fnMeasurement = {'deviation','P','intensity','intensity_rescaled'};
            for k = 1:length(fibrilStatistics)
                singleSites{k}.fibrilStatistics = fibrilStatistics{k};
                singleSites{k}.fibrilStatistics.kymograph = [];
                singleSites{k}.fibrilStatistics.GuiParameters = [];
                for l = 1:4
                    singleSites{k}.fibrilStatistics.measurement.(fnMeasurement{l}).raw = [];
                    singleSites{k}.fibrilStatistics.measurement.(fnMeasurement{l}).fft = [];
                end
                singleSites{k}.fibrilDynamics = fibrilDynamics{k};
                singleSites{k}.fibrilDynamics.GuiParameters = [];
                singleSites{k}.fibrilStraightener = fibrilStraightener{k};
                singleSites{k}.fibrilStraightener.indFibrilLocs = [];
            end
            uisave('singleSites', defaultFn)
            obj.status('save done')
            out = [];
        end
        function pard=guidef(obj)
           pard.plugininfo.type='SaverPlugin';
        end
        function out = run(obj,p)
            obj.save(p)
            out = [];
        end        

    end
end
