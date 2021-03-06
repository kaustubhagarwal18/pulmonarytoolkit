classdef PTKEditBox < PTKUserInterfaceObject
    % PTKEditBox. Part of the gui for the Pulmonary Toolkit.
    %
    %     This class is used internally within the Pulmonary Toolkit to help
    %     build the user interface.
    %
    %     PTKEditBox is used to build a text box with editing capabaility
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. http://code.google.com/p/pulmonarytoolkit
    %     Author: Tom Doel, 2014.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %
        
    properties (SetAccess = private)
        Text
        TextSetInProgress % Used to stop a forced change in the text value triggering a change notification
        ToolTip
        Highlighted        
    end
    
    properties
        FontSize
        Bold
        FontColour
        HorizontalAlignment
        SelectedColour
        SelectedFontColour
        BackgroundColour
        TextBoxWidth = 15
    end
    
    events
        TextChanged % The text has been changed by the user
    end
    
    methods
        function obj = PTKEditBox(parent, tooltip)
            obj = obj@PTKUserInterfaceObject(parent);
            obj.FontSize = 11;
            obj.Text = '';
            obj.TextSetInProgress = false;
            obj.Bold = false;
            obj.Highlighted = false;
            obj.ToolTip = tooltip;
            obj.HorizontalAlignment = 'left';
            obj.FontColour = PTKSoftwareInfo.TextPrimaryColour;
            obj.SelectedColour = PTKSoftwareInfo.SelectedBackgroundColour;
            obj.SelectedFontColour = PTKSoftwareInfo.TextContrastColour;
            obj.BackgroundColour = PTKSoftwareInfo.BackgroundColour; 
        end

        function CreateGuiComponent(obj, position, reporting)
            
            if obj.Bold
                weight = 'bold';
            else
                weight = 'normal';
            end
            
            obj.GraphicalComponentHandle = uicontrol('Style', 'edit', ...
                'Parent', obj.Parent.GetContainerHandle, 'Units', 'pixels', ...
                'FontSize', obj.FontSize, 'Position', position, 'Callback', @obj.TextCallback, ...
                'BackgroundColor', obj.BackgroundColour, 'ForegroundColor', obj.FontColour, ...
                'FontAngle', 'normal', 'FontUnits', 'pixels', 'FontSize', obj.FontSize, ...
                'HorizontalAlignment', obj.HorizontalAlignment, 'FontWeight', weight, ...
                'TooltipString', obj.ToolTip, 'String', obj.Text);
        end
        
        function SetText(obj, string)
            obj.Text = string;
            if obj.ComponentHasBeenCreated
                obj.TextSetInProgress = true;
                set(obj.GraphicalComponentHandle, 'String', string);
                obj.TextSetInProgress = false;
            end
        end
        
        function Highlight(obj, highlighted)
            if (highlighted ~= obj.Highlighted)
                obj.Highlighted = highlighted;
                obj.UpdateBackgroundColour;
            end
        end
        
    end
    
    methods (Access = protected)
        function input_has_been_processed = MouseHasMoved(obj, click_point, selection_type, src)
            % This method is called when the mouse is moved

            obj.Highlight(true);
            input_has_been_processed = true;
        end

        function input_has_been_processed = MouseExit(obj, click_point, selection_type, src)
            % This method is called when the mouse exits a control which previously
            % processed a MouseHasMoved event
            
            obj.Highlight(false);
            input_has_been_processed = true;
        end
        
    end
    
    
    
    methods (Access = private)
        function TextCallback(obj, hObject, ~, ~)
            if ~obj.TextSetInProgress
                new_string = get(obj.GraphicalComponentHandle, 'String');
                obj.Text = new_string;
                notify(obj, 'TextChanged');
            end
        end
        
        function UpdateBackgroundColour(obj)
            if ~isempty(obj.GraphicalComponentHandle)
                background_colour = obj.BackgroundColour;
                text_colour = obj.FontColour;

                if obj.Highlighted
                    background_colour = min(1, background_colour + 0.2);
                end
                set(obj.GraphicalComponentHandle, 'BackgroundColor', background_colour, 'ForegroundColor', text_colour);
            end
        end
        
    end
end