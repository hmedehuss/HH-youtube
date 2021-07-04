classdef Feedforward_app_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure               matlab.ui.Figure
        massekgEditFieldLabel  matlab.ui.control.Label
        massekgEditField       matlab.ui.control.NumericEditField
        LmEditField            matlab.ui.control.NumericEditField
        LmEditFieldLabel       matlab.ui.control.Label
        cNmradsEditField       matlab.ui.control.NumericEditField
        cNmradsEditFieldLabel  matlab.ui.control.Label
        RunsimulationButton    matlab.ui.control.Button
        ParameterSweep         matlab.ui.control.Table
        MasseSweepButton       matlab.ui.control.Button
        CompareFFButton        matlab.ui.control.Button
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.ParameterSweep.Data = [0 0 1];
        end

        % Button pushed function: RunsimulationButton
        function RunsimulationButtonPushed(app, event)
            g = 9.8; % m/s2
            m = app.massekgEditField.Value; % kg
            c = app.cNmradsEditField.Value; % Nm/rad/s
            L = app.LmEditField.Value; % m
            theta0 = 0; % rad
            thetadot0 =0; %rad/s
            
            mdl = 'Models_PID';
            open_system(mdl);
            in = Simulink.SimulationInput(mdl);
            in = in.setVariable('m', m);
            in = in.setVariable('g', g);
            in = in.setVariable('L', L);
            in = in.setVariable('c', c);
            in = in.setVariable('theta0', theta0);
            in = in.setVariable('thetadot0', thetadot0);
            
            out = sim(in);
            
            %%
            Simulink.sdi.clear;
            Simulink.sdi.setSubPlotLayout(2,1);
            Run = Simulink.sdi.Run.create;
            Run.Name = 'single Run'
            Att = out.Att;
            add(Run, 'vars', Att);
            thetaid = getSignalIDsByName(Run, 'theta');
            Dthetaid = getSignalIDsByName(Run, 'Dtheta');
            theta = Simulink.sdi.getSignal(thetaid);
            Dtheta = Simulink.sdi.getSignal(Dthetaid)
            plotOnSubPlot(theta,1,1,true);
            plotOnSubPlot(Dtheta,2,1,true);
            Simulink.sdi.view
            
            
            
            
            
        end

        % Button pushed function: MasseSweepButton
        function MasseSweepButtonPushed(app, event)
            g = 9.8; % m/s2
            c = app.cNmradsEditField.Value; % Nm/rad/s
            L = app.LmEditField.Value; % m
            theta0 = 0; % rad
            thetadot0 =0; %rad/s
            
            Masse_Min =  app.ParameterSweep.Data(1,1);
            
            Masse_Max =  app.ParameterSweep.Data(1,2);
            
            Masse_Step =  app.ParameterSweep.Data(1,3);
            
            Masse_vals = Masse_Min:Masse_Step:Masse_Max;
            
            numSims = length(Masse_vals);
            
            
            mdl = 'Models_PID';
            open_system(mdl);
            in(1:numSims) = Simulink.SimulationInput(mdl);
            in(1:numSims) = in(1:numSims).setVariable('g', g);
            in(1:numSims) = in(1:numSims).setVariable('L', L);
            in(1:numSims) = in(1:numSims).setVariable('c', c);
            in(1:numSims) = in(1:numSims).setVariable('theta0', theta0);
            in(1:numSims) = in(1:numSims).setVariable('thetadot0', thetadot0);
            
           
            
            Simulink.sdi.clear;
            Simulink.sdi.setSubPlotLayout(2,1);

           
           
            
            
            
            for i=1:numSims
                in(i) = in(i).setVariable('m', Masse_vals(i));
                out(i) = sim(in(i));
                Run = Simulink.sdi.Run.create;
                Run.Name = ['Run' num2str(i)]
                Att = out(i).Att;
                add(Run, 'vars', Att);
                thetaid = getSignalIDsByName(Run, 'theta');
                Dthetaid = getSignalIDsByName(Run, 'Dtheta');
                theta = Simulink.sdi.getSignal(thetaid);
                Dtheta = Simulink.sdi.getSignal(Dthetaid)
                plotOnSubPlot(theta,1,1,true);
                plotOnSubPlot(Dtheta,2,1,true);
            end
            
            
            Simulink.sdi.view
        end

        % Button pushed function: CompareFFButton
        function CompareFFButtonPushed(app, event)
            g = 9.8; % m/s2
            c = app.cNmradsEditField.Value; % Nm/rad/s
            L = app.LmEditField.Value; % m
            theta0 = 0; % rad
            thetadot0 =0; %rad/s
            m = app.massekgEditField.Value; % kg
            
            
            mdl = 'Models_PID_FF';
            open_system(mdl);
            in(1:2) = Simulink.SimulationInput(mdl);
            in(1:2) = in(1:2).setVariable('g', g);
            in(1:2) = in(1:2).setVariable('L', L);
            in(1:2) = in(1:2).setVariable('c', c);
            in(1:2) = in(1:2).setVariable('theta0', theta0);
            in(1:2) = in(1:2).setVariable('thetadot0', thetadot0);
            in(1) = in(1).setVariable('Activate_FF', false);
            in(2) = in(2).setVariable('Activate_FF', true);
           
            
            Simulink.sdi.clear;
            Simulink.sdi.setSubPlotLayout(2,1);

           
           
            
            
            
            for i=1:2
                out(i) = sim(in(i));
                Run = Simulink.sdi.Run.create;
                if i==1
                Run.Name = 'No FF'; 
                else Run.Name = 'FF' ;
                end
             
                Att = out(i).Att;
                add(Run, 'vars', Att);
                thetaid = getSignalIDsByName(Run, 'theta');
                Dthetaid = getSignalIDsByName(Run, 'Dtheta');
                theta = Simulink.sdi.getSignal(thetaid);
                Dtheta = Simulink.sdi.getSignal(Dthetaid);
                plotOnSubPlot(theta,1,1,true);
                plotOnSubPlot(Dtheta,2,1,true);
            end
            
            
            Simulink.sdi.view
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create massekgEditFieldLabel
            app.massekgEditFieldLabel = uilabel(app.UIFigure);
            app.massekgEditFieldLabel.HorizontalAlignment = 'right';
            app.massekgEditFieldLabel.Position = [231 442 64 22];
            app.massekgEditFieldLabel.Text = 'masse (kg)';

            % Create massekgEditField
            app.massekgEditField = uieditfield(app.UIFigure, 'numeric');
            app.massekgEditField.Position = [310 442 100 22];
            app.massekgEditField.Value = 1;

            % Create LmEditField
            app.LmEditField = uieditfield(app.UIFigure, 'numeric');
            app.LmEditField.Position = [310 379 100 22];
            app.LmEditField.Value = 1;

            % Create LmEditFieldLabel
            app.LmEditFieldLabel = uilabel(app.UIFigure);
            app.LmEditFieldLabel.HorizontalAlignment = 'right';
            app.LmEditFieldLabel.Position = [262 379 33 22];
            app.LmEditFieldLabel.Text = 'L (m)';

            % Create cNmradsEditField
            app.cNmradsEditField = uieditfield(app.UIFigure, 'numeric');
            app.cNmradsEditField.Position = [310 324 100 22];
            app.cNmradsEditField.Value = 0.5;

            % Create cNmradsEditFieldLabel
            app.cNmradsEditFieldLabel = uilabel(app.UIFigure);
            app.cNmradsEditFieldLabel.HorizontalAlignment = 'right';
            app.cNmradsEditFieldLabel.Position = [218 324 77 22];
            app.cNmradsEditFieldLabel.Text = 'c (N.m /rad/s)';

            % Create RunsimulationButton
            app.RunsimulationButton = uibutton(app.UIFigure, 'push');
            app.RunsimulationButton.ButtonPushedFcn = createCallbackFcn(app, @RunsimulationButtonPushed, true);
            app.RunsimulationButton.Position = [64 33 100 22];
            app.RunsimulationButton.Text = 'Run simulation';

            % Create ParameterSweep
            app.ParameterSweep = uitable(app.UIFigure);
            app.ParameterSweep.ColumnName = {'Min'; 'Max'; 'step'};
            app.ParameterSweep.RowName = {'masse'};
            app.ParameterSweep.ColumnEditable = true;
            app.ParameterSweep.Position = [163 110 302 185];

            % Create MasseSweepButton
            app.MasseSweepButton = uibutton(app.UIFigure, 'push');
            app.MasseSweepButton.ButtonPushedFcn = createCallbackFcn(app, @MasseSweepButtonPushed, true);
            app.MasseSweepButton.Position = [271 33 100 22];
            app.MasseSweepButton.Text = 'Masse Sweep';

            % Create CompareFFButton
            app.CompareFFButton = uibutton(app.UIFigure, 'push');
            app.CompareFFButton.ButtonPushedFcn = createCallbackFcn(app, @CompareFFButtonPushed, true);
            app.CompareFFButton.Position = [464 33 100 22];
            app.CompareFFButton.Text = 'Compare FF';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Feedforward_app_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end