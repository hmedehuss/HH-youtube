classdef Parallel_OPT_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                matlab.ui.Figure
        TabGroup                matlab.ui.container.TabGroup
        NormalTab               matlab.ui.container.Tab
        RunsimulationButton     matlab.ui.control.Button
        ParameterSweep          matlab.ui.control.Table
        MasseSweepButton        matlab.ui.control.Button
        CompareFFButton         matlab.ui.control.Button
        massekgEditFieldLabel   matlab.ui.control.Label
        massekgEditField        matlab.ui.control.NumericEditField
        LmEditField             matlab.ui.control.NumericEditField
        LmEditFieldLabel        matlab.ui.control.Label
        cNmradsEditField        matlab.ui.control.NumericEditField
        cNmradsEditFieldLabel   matlab.ui.control.Label
        OPTTab                  matlab.ui.container.Tab
        RunOPTButton            matlab.ui.control.StateButton
        GainSweep               matlab.ui.control.Table
        SweepGainFindMaxButton  matlab.ui.control.StateButton
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            app.ParameterSweep.Data = [0 0 1];
            app.GainSweep.Data = [0 0 1; 0 0 1; 0 0 1];
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
            in(1:2) = in(1:2).setVariable('m', m);
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

        % Value changed function: RunOPTButton
        function RunOPTButtonValueChanged(app, event)
            g = 9.8; % m/s2
            m = app.massekgEditField.Value; % kg
            c = app.cNmradsEditField.Value; % Nm/rad/s
            L = app.LmEditField.Value; % m
            theta0 = 0; % rad
            thetadot0 =0; %rad/s
            
            mdl = 'Models_PID_OPT';
            load_system(mdl);
            in = Simulink.SimulationInput(mdl);
            in = in.setVariable('m', m);
            in = in.setVariable('g', g);
            in = in.setVariable('L', L);
            in = in.setVariable('c', c);
            in = in.setVariable('theta0', theta0);
            in = in.setVariable('thetadot0', thetadot0);
            in = in.setVariable('Activate_FF', true);
            
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

        % Value changed function: SweepGainFindMaxButton
        function SweepGainFindMaxButtonValueChanged(app, event)
            g = 9.8; % m/s2
            c = app.cNmradsEditField.Value; % Nm/rad/s
            m = app.massekgEditField.Value; % kg
            L = app.LmEditField.Value; % m
            theta0 = 0; % rad
            thetadot0 =0; %rad/s
            Kp = app.GainSweep.Data(1,1);
            Ki = app.GainSweep.Data(2,1);
            Kd = app.GainSweep.Data(3,1);
            
            Kp_Min =  app.GainSweep.Data(1,1);
            Kp_Max =  app.GainSweep.Data(1,2);
            Kp_Step =  app.GainSweep.Data(1,3);
            
            Ki_Min =  app.GainSweep.Data(2,1);
            Ki_Max =  app.GainSweep.Data(2,2);
            Ki_Step =  app.GainSweep.Data(2,3);
            
            Kd_Min =  app.GainSweep.Data(3,1);
            Kd_Max =  app.GainSweep.Data(3,2);
            Kd_Step =  app.GainSweep.Data(3,3);
            
            Kp_vals = Kp_Min:Kp_Step:Kp_Max;
            Ki_vals = Ki_Min:Ki_Step:Ki_Max;
            Kd_vals = Kd_Min:Kd_Step:Kd_Max;
            
            numSims = length(Kp_vals)*length(Ki_vals)*length(Kd_vals);
            
            
            mdl = 'Parallel_OPT';
            load_system(mdl);
            in(1:numSims) = Simulink.SimulationInput(mdl);
            in(1:numSims) = in(1:numSims).setVariable('g', g);
            in(1:numSims) = in(1:numSims).setVariable('L', L);
            in(1:numSims) = in(1:numSims).setVariable('m', m);
            in(1:numSims) = in(1:numSims).setVariable('c', c);
            in(1:numSims) = in(1:numSims).setVariable('theta0', theta0);
            in(1:numSims) = in(1:numSims).setVariable('thetadot0', thetadot0);
            
            
            
            Simulink.sdi.clear;
            Simulink.sdi.setSubPlotLayout(2,1);
            
            
            
            
            idx = 1;
            
            for i=1:length(Kp_vals)
                for j=1:length(Ki_vals)
                    for k=1:length(Kd_vals)
                        
                        in(idx) = in(idx).setVariable('Kp', Kp_vals(i));
                        in(idx) = in(idx).setVariable('Ki', Ki_vals(j));
                        in(idx) = in(idx).setVariable('Kd', Kd_vals(k));
                        out(idx) = sim(in(idx));
                        Run = Simulink.sdi.Run.create;
                        Run.Name = ['Run' num2str(idx)];
                        CostFun(idx) = out(idx).CostFun.Data(end,1);
                        Tested_Kp(idx) =  Kp_vals(i);
                        Tested_Ki(idx) =  Ki_vals(j);
                        Tested_Kd(idx) =  Kd_vals(k);
                        Att = out(idx).Att;
                        add(Run, 'vars', Att);
                        thetaid = getSignalIDsByName(Run, 'theta');
                        Dthetaid = getSignalIDsByName(Run, 'Dtheta');
                        theta = Simulink.sdi.getSignal(thetaid);
                        Dtheta = Simulink.sdi.getSignal(Dthetaid)
                        plotOnSubPlot(theta,1,1,true);
                        plotOnSubPlot(Dtheta,2,1,true);
                        idx = idx + 1;
                    end
                end
            end
            
            
            Simulink.sdi.view
            
            [min_val, min_idx] = max(CostFun);
            
            msgbox(sprintf(['Operation Completed, with Min_Cost = %f for Run = %d and gains ' ...
                '\n Kp=%f Ki=%f Kd=%f'], min_val, min_idx, Tested_Kp(min_idx), Tested_Ki(min_idx), ...
                Tested_Kd(min_idx) ), 'Summary');
            
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

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [1 2 640 479];

            % Create NormalTab
            app.NormalTab = uitab(app.TabGroup);
            app.NormalTab.Title = 'Normal';

            % Create RunsimulationButton
            app.RunsimulationButton = uibutton(app.NormalTab, 'push');
            app.RunsimulationButton.ButtonPushedFcn = createCallbackFcn(app, @RunsimulationButtonPushed, true);
            app.RunsimulationButton.Position = [8 15 100 22];
            app.RunsimulationButton.Text = 'Run simulation';

            % Create ParameterSweep
            app.ParameterSweep = uitable(app.NormalTab);
            app.ParameterSweep.ColumnName = {'Min'; 'Max'; 'step'};
            app.ParameterSweep.RowName = {'masse'};
            app.ParameterSweep.ColumnEditable = true;
            app.ParameterSweep.Position = [107 92 302 185];

            % Create MasseSweepButton
            app.MasseSweepButton = uibutton(app.NormalTab, 'push');
            app.MasseSweepButton.ButtonPushedFcn = createCallbackFcn(app, @MasseSweepButtonPushed, true);
            app.MasseSweepButton.Position = [215 15 100 22];
            app.MasseSweepButton.Text = 'Masse Sweep';

            % Create CompareFFButton
            app.CompareFFButton = uibutton(app.NormalTab, 'push');
            app.CompareFFButton.ButtonPushedFcn = createCallbackFcn(app, @CompareFFButtonPushed, true);
            app.CompareFFButton.Position = [408 15 100 22];
            app.CompareFFButton.Text = 'Compare FF';

            % Create massekgEditFieldLabel
            app.massekgEditFieldLabel = uilabel(app.NormalTab);
            app.massekgEditFieldLabel.HorizontalAlignment = 'right';
            app.massekgEditFieldLabel.Position = [175 424 64 22];
            app.massekgEditFieldLabel.Text = 'masse (kg)';

            % Create massekgEditField
            app.massekgEditField = uieditfield(app.NormalTab, 'numeric');
            app.massekgEditField.Position = [254 424 100 22];
            app.massekgEditField.Value = 1;

            % Create LmEditField
            app.LmEditField = uieditfield(app.NormalTab, 'numeric');
            app.LmEditField.Position = [254 361 100 22];
            app.LmEditField.Value = 1;

            % Create LmEditFieldLabel
            app.LmEditFieldLabel = uilabel(app.NormalTab);
            app.LmEditFieldLabel.HorizontalAlignment = 'right';
            app.LmEditFieldLabel.Position = [206 361 33 22];
            app.LmEditFieldLabel.Text = 'L (m)';

            % Create cNmradsEditField
            app.cNmradsEditField = uieditfield(app.NormalTab, 'numeric');
            app.cNmradsEditField.Position = [254 306 100 22];
            app.cNmradsEditField.Value = 0.5;

            % Create cNmradsEditFieldLabel
            app.cNmradsEditFieldLabel = uilabel(app.NormalTab);
            app.cNmradsEditFieldLabel.HorizontalAlignment = 'right';
            app.cNmradsEditFieldLabel.Position = [162 306 77 22];
            app.cNmradsEditFieldLabel.Text = 'c (N.m /rad/s)';

            % Create OPTTab
            app.OPTTab = uitab(app.TabGroup);
            app.OPTTab.Title = 'OPT';

            % Create RunOPTButton
            app.RunOPTButton = uibutton(app.OPTTab, 'state');
            app.RunOPTButton.ValueChangedFcn = createCallbackFcn(app, @RunOPTButtonValueChanged, true);
            app.RunOPTButton.Text = 'Run OPT';
            app.RunOPTButton.Position = [220 334 167 112];

            % Create GainSweep
            app.GainSweep = uitable(app.OPTTab);
            app.GainSweep.ColumnName = {'Min'; 'Max'; 'step'};
            app.GainSweep.RowName = {'Kp'; 'Ki'; 'Kd'; ''};
            app.GainSweep.ColumnEditable = true;
            app.GainSweep.Position = [169 136 302 185];

            % Create SweepGainFindMaxButton
            app.SweepGainFindMaxButton = uibutton(app.OPTTab, 'state');
            app.SweepGainFindMaxButton.ValueChangedFcn = createCallbackFcn(app, @SweepGainFindMaxButtonValueChanged, true);
            app.SweepGainFindMaxButton.Text = 'Sweep Gain & Find Max';
            app.SweepGainFindMaxButton.Position = [220 15 167 112];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = Parallel_OPT_exported

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