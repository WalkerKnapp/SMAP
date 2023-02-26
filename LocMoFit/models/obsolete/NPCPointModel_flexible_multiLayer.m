classdef NPCPointModel_flexible2<geometricModel
    
    % log
    %   - 201229: change the sign of the ring twist
    methods
        function obj = NPCPointModel_flexible2(varargin)
            obj@geometricModel(varargin{:});
            % Define parameters that can be altered during fitting here:
            obj.name = {'ringDistance', 'azimuthalShift', 'radius', 'cornerDegree'}; % parameter names
            obj.fix = [0 0 1 1] ;                                                    % fix to a constant or not
            obj.value = [0 0 53.7 12];                                               % initial guess
            obj.lb = [0 -inf 0 0];                                                   % relative lower bound
            obj.ub = [70 inf 0 22.5];                                                % relative upper bound
            obj.min = [0 -inf 0 -inf];                                               % absolute lower bound
            obj.max = [70 inf 100 inf];                                              % absolute upper bound
            
            % Define discrite parameters here:
            obj.internalSettings.copyPerCorner = 2;
            obj.internalSettings.cornerNum = 8;
            obj.internalSettings.ringLayer = 1;
            
            % Define other properties here:
            obj.modelType = 'discrete';
            obj.modelTypeOption = {'discrete'};
            obj.dimension = 3;
            
        end
        
        function [model, p]= reference(obj, par, dx)
        % Sample coordinates of the model as reference.
        % --- Syntax ---
        % [model, p]= reference(obj, par, dx)
        % --- Arguments ---
        % -- Input --
        % obj:
        % par: a structure object. Its fieldnames should be the names of
        % parameters, and their correspoinding content should be the
        % parameter values.
        % dx: sampling rate.
        % -- Output --
        % model: a structure object. Its fieldnames should be x, y, z, and
        % n, indicating the xyz position amplitude n of the sampled model
        % points.
        % p: additional information of the model.
        
        
        % set additional parameters of the model
        ip = inputParser;
        fn = fieldnames(obj.internalSettings);
        for k = 1:length(fn)
            ip.addParameter(fn{k}, obj.internalSettings.(fn{k}));
        end
        a = {};
        parse(ip,a{:})
        pResults = ip.Results;
        
        copyPerCorner = pResults.copyPerCorner;
        cornerNum = pResults.cornerNum;
        useSecondRing = pResults.useSecondRing;
        cornerRange = par.cornerDegree;
        
        % corner:
        cornerPos = linspace(0,2*pi,cornerNum+1);
        cornerPos = cornerPos(1:end-1);
        
        % copies in one corner:
        for k=length(cornerRange):-1:1
            copyPos(:,k) = linspace(0,cornerRange(k)*pi/180,copyPerCorner)-cornerRange(k)*pi/360; % the last term is for aligning the corners among different cornerRange
        end
        
        % copies in all corners of one ring
        cornerPosNew(1,1,:) = cornerPos;
        allCopiesTheta = copyPos + cornerPosNew;
        
        % vecterization
        fn = fieldnames(par);
        maxParElem = 0;
        for k = 1:length(fn)
            maxParElem = max([maxParElem length(par.(fn{k}))]);
        end
        tempTheta = zeros([1 maxParElem]);              % this is for the vecterization
        if size(allCopiesTheta,2)==1
            allCopiesTheta = allCopiesTheta(:)+tempTheta;
        else
            allCopiesTheta = permute(allCopiesTheta, [1 3 2]);
            allCopiesTheta = reshape(allCopiesTheta,prod(size(allCopiesTheta,[1 2])),size(allCopiesTheta,3));
        end
        par.radius = tempTheta+par.radius;
        
        % assign the radius for each copy
        allCopiesRho = repelem(par.radius', size(allCopiesTheta,1));
        
        % convert from polar coordinates
        [allCopiesX,allCopiesY]= pol2cart(allCopiesTheta(:), allCopiesRho(:));
        allCopiesX = reshape(allCopiesX,size(allCopiesTheta));
        allCopiesY = reshape(allCopiesY,size(allCopiesTheta));
        
        % for the second ring
        if useSecondRing
            allCopiesThetaRing2 = allCopiesTheta-par.azimuthalShift.*pi./180;
            [allCopiesXRing2,allCopiesYRing2]= pol2cart(allCopiesThetaRing2(:), allCopiesRho(:));
            allCopiesXRing2 = reshape(allCopiesXRing2,size(allCopiesTheta));
            allCopiesYRing2 = reshape(allCopiesYRing2,size(allCopiesTheta));
            halfRingDist = par.ringDistance./2;
            allCopiesZ = zeros(size(allCopiesX))+halfRingDist;
            allCopiesZRing2 = zeros(size(allCopiesXRing2))-halfRingDist;
            model.x = [allCopiesX;allCopiesXRing2];
            model.y = [allCopiesY;allCopiesYRing2];
            model.z = [allCopiesZ;allCopiesZRing2];
        else
            allCopiesZ = zeros(size(allCopiesX));
            model.x = allCopiesX;
            model.y = allCopiesY;
            model.z = allCopiesZ;
        end
        model.channel = ones(size(model.x));
        model.n = ones(size(model.x));

        %     likelihood = gaussDist(model,double(locs.ynmrot), double(locs.xnmrot), double(locs.znm), 8,8,10);
        %     likelihoodBoun = gaussDist(model,0,0,0, 16,16,20);

        p.cornerRange=cornerRange;
        p.copyPerCorner=copyPerCorner;
        p.cornerNum=cornerNum;
        end
        function derivedPars = getDerivedPars(obj, pars)
            derivedPars = [];
        end
    end
end
