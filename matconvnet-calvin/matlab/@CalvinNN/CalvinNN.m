classdef CalvinNN < handle
    % CalvinNN
    %
    % Default network training script in Matconvnet-Calvin.
    % This uses Matconvnet's Directed Acyclic Graph structure and is
    % heavily inspired by the cnn_train_dag example.
    %
    % Copyright by Holger Caesar, 2015
    
    properties
        net
        imdb
        nnOpts
        stats
    end
    
    methods
        function obj = CalvinNN(net, imdb, nnOpts)
            % obj = CalvinNN(net, imdb, [nnOpts])
            
            % Default arguments
            if ~exist('nnOpts', 'var')
                nnOpts = struct();
            end
            
            % Set imdb
            obj.imdb = imdb;
            
            % Init options and GPUs
            obj.init(nnOpts);
            
            % Check if previous snapshots exist
            prevEpoch = obj.nnOpts.continue * CalvinNN.findLastCheckpoint(obj.nnOpts.expDir);
            if isnan(prevEpoch)
                % No checkpoint found
                % Load network and convert to DAG format
                obj.loadNetwork(net);
                
                if obj.nnOpts.convertToTrain
                    % Convert network from test to train (add loss layer,
                    % dropout etc.)
                    obj.convertNetwork();
                end
                
                % Save untrained net
                fprintf('Saving untrained network...\n');
                prevEpoch = 0;
                obj.saveState(obj.nnOpts.modelPath(prevEpoch));
            else
                % Load existing checkpoint and continue
                prevEpoch = obj.nnOpts.continue * prevEpoch;
                fprintf('Resuming by loading epoch %d...\n', prevEpoch);
                [obj.net, obj.stats] = CalvinNN.loadState(obj.nnOpts.modelPath(prevEpoch));
            end
        end 
        
        % Declarations for methods that are in separate files
        convertNetwork(obj, net);
        convertNetworkToFastRcnn(obj, varargin);
        init(obj, varargin);
        plotStats(obj, epochs, stats, plotAccuracy);
        saveState(obj, fileName);
        statsTest = test(obj);
        train(obj);
    end
    
    methods (Access = protected)
        % Declarations for methods that are in separate files
        stats = accumulateStats(obj, stats_);
        state = accumulateGradients(obj, state, net, batchSize);
        stats = processEpoch(obj, net, state);
    end
    
    methods (Static)
        stats = extractStats(net, inputs);
        epoch = findLastCheckpoint(modelDir);
        [net, stats] = loadState(obj, fileName);
    end
end