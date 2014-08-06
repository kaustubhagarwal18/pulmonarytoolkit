classdef PTKViewerPanelCallback < handle
    % PTKViewerPanelCallback. Class to handle PTKViewerPanel callback events
    %
    %
    %
    %     Licence
    %     -------
    %     Part of the TD Pulmonary Toolkit. http://code.google.com/p/pulmonarytoolkit
    %     Author: Tom Doel, 2014.  www.tomdoel.com
    %     Distributed under the GNU GPL v3 licence. Please see website for details.
    %
    
    properties (Access = private)
        
        % Handles for callbacks to udate the GUI
        Tools
        Toolbar
        ViewerPanel
        ViewerPanelRenderer
        Reporting
        
        % Handles to listeners for image changes
        BackgroundImageChangedListener
        OverlayImageChangedListener
        QuiverImageChangedListener
        
    end
    
    methods
        
        function obj = PTKViewerPanelCallback(viewing_panel, viewing_panel_renderer, tools, toolbar, reporting)
            obj.Tools = tools;
            obj.Toolbar = toolbar;
            obj.ViewerPanel = viewing_panel;
            obj.ViewerPanelRenderer = viewing_panel_renderer;
            obj.Reporting = reporting;
            
            obj.NewBackgroundImage;
            obj.NewOverlayImage;
            obj.NewQuiverImage;
            
            % Change in orientation requires a redraw of axes
            addlistener(obj.ViewerPanel, 'Orientation', 'PostSet', @obj.OrientationChangedCallback);
            
            % Other changes require redraw of gui
            addlistener(obj.ViewerPanel, 'SliceNumber', 'PostSet', @obj.SliceNumberChangedCallback);
            addlistener(obj.ViewerPanel, 'Level', 'PostSet', @obj.SettingsChangedCallback);
            addlistener(obj.ViewerPanel, 'Window', 'PostSet', @obj.SettingsChangedCallback);
            addlistener(obj.ViewerPanel, 'OverlayOpacity', 'PostSet', @obj.SettingsChangedCallback);
            addlistener(obj.ViewerPanel, 'ShowImage', 'PostSet', @obj.SettingsChangedCallback);
            addlistener(obj.ViewerPanel, 'ShowOverlay', 'PostSet', @obj.SettingsChangedCallback);
            addlistener(obj.ViewerPanel, 'BlackIsTransparent', 'PostSet', @obj.SettingsChangedCallback);
            addlistener(obj.ViewerPanel, 'OpaqueColour', 'PostSet', @obj.SettingsChangedCallback);
            
            % Listen for image change events
            addlistener(obj.ViewerPanel, 'BackgroundImage', 'PostSet', @obj.ImagePointerChangedCallback);
            addlistener(obj.ViewerPanel, 'OverlayImage', 'PostSet', @obj.OverlayImagePointerChangedCallback);
            addlistener(obj.ViewerPanel, 'QuiverImage', 'PostSet', @obj.QuiverImagePointerChangedCallback);
        end
        
        function delete(obj)
            PTKSystemUtilities.DeleteIfHandle(obj.BackgroundImageChangedListener)
            PTKSystemUtilities.DeleteIfHandle(obj.OverlayImageChangedListener)
            PTKSystemUtilities.DeleteIfHandle(obj.QuiverImageChangedListener)
        end
        
    end
    
    methods (Access = private)
        
        function NewBackgroundImage(obj)
            
            % Check that this image is the correct class type
            if ~isa(obj.ViewerPanel.BackgroundImage, 'PTKImage')
                error('The image must be of class PTKImage');
            end
            
            % Update the panel
            obj.ImageChanged;
            
            % Remove existing listener
            PTKSystemUtilities.DeleteIfValid(obj.BackgroundImageChangedListener);
            
            % Listen for image change events
            obj.BackgroundImageChangedListener = addlistener(obj.ViewerPanel.BackgroundImage, 'ImageChanged', @obj.ImageChangedCallback);
        end
        
        
        function NewOverlayImage(obj)
            
            % Check that this image is the correct class type
            if ~isa(obj.ViewerPanel.OverlayImage, 'PTKImage')
                error('The image must be of class PTKImage');
            end
            
            no_current_image = ~obj.ViewerPanel.BackgroundImage.ImageExists;
            
            % Update the panel
            if no_current_image % We need to set the axes initially, otherwise the overlay will not appear until UpdateAxes is called
                obj.ImageChanged;
            else
                obj.OverlayImageChanged;
            end
            
            % Remove existing listener
            PTKSystemUtilities.DeleteIfValid(obj.OverlayImageChangedListener);
            
            % Listen for image change events
            obj.OverlayImageChangedListener = addlistener(obj.ViewerPanel.OverlayImage, 'ImageChanged', @obj.OverlayImageChangedCallback);
        end
        
        function NewQuiverImage(obj)
            
            % Check that this image is the correct class type
            if ~isa(obj.ViewerPanel.QuiverImage, 'PTKImage')
                error('The image must be of class PTKImage');
            end
            
            no_current_image = ~obj.ViewerPanel.BackgroundImage.ImageExists;
            
            % Update the panel
            if no_current_image % We need to set the axes initially, otherwise the overlay will not appear until UpdateAxes is called
                obj.ImageChanged;
            else
                obj.OverlayImageChanged;
            end
            
            % Remove existing listener
            PTKSystemUtilities.DeleteIfValid(obj.QuiverImageChangedListener);
            
            % Listen for image change events
            obj.QuiverImageChangedListener = addlistener(obj.ViewerPanel.QuiverImage, 'ImageChanged', @obj.OverlayImageChangedCallback);
        end
        
        function ImageChangedCallback(obj, ~, ~)
            % This methods is called when the background image has changed
            
            obj.ImageChanged;
        end

        function OverlayImageChangedCallback(obj, ~, ~)
            % This methods is called when the overlay image has changed
            
            obj.OverlayImageChanged;
        end
        
        function OrientationChangedCallback(obj, ~, ~)
            % This methods is called when the orientation has changed
            
            obj.ViewerPanelRenderer.UpdateAxes;
            obj.UpdateGuiForNewOrientation;
            obj.UpdateGui;
            obj.ViewerPanelRenderer.DrawImages(true, true, true);
            obj.UpdateStatus;
            obj.Tools.NewOrientation;
        end
        
        function SliceNumberChangedCallback(obj, ~, ~, ~)
            % This methods is called when the slice number has changed
            
            obj.UpdateGui;
            obj.Tools.NewSlice;
            obj.ViewerPanelRenderer.DrawImages(true, true, true);
            obj.UpdateStatus;
        end
        
        function SettingsChangedCallback(obj, ~, ~, ~)
            % This methods is called when the settings have changed
            
            % If the window or level values have been externally set outside the
            % slider range, then we modify the slider range to accommodate this
            obj.Toolbar.ModifyWindowLevelLimits;
            
            obj.UpdateGui;
            obj.ViewerPanelRenderer.DrawImages(true, true, true);
            obj.UpdateStatus;
        end
        
        function ImagePointerChangedCallback(obj, ~, ~)
            % Image pointer has changed
            
            obj.NewBackgroundImage;
        end
        
        function OverlayImagePointerChangedCallback(obj, ~, ~)
            % Overlay image pointer has changed
            
            obj.NewOverlayImage;
        end
        
        function QuiverImagePointerChangedCallback(obj, ~, ~)
            % Quiver image pointer has changed
            
            obj.NewQuiverImage;
        end
        
        function ImageChanged(obj)
            % This function is called when the background image is modified
            
            obj.ViewerPanelRenderer.ClearAxesCache;
            obj.AutoChangeOrientation;
            obj.ViewerPanelRenderer.UpdateAxes;
            obj.UpdateGuiForNewImage;
            obj.UpdateGuiForNewOrientation;
            obj.UpdateGui;
            obj.ViewerPanelRenderer.DrawImages(true, false, false);
            obj.UpdateStatus;
            
            obj.Tools.ImageChanged;
        end
        
        function OverlayImageChanged(obj)
            % This function is called when the overlay image is modified
            
            obj.ViewerPanelRenderer.UpdateAxes;
            obj.ViewerPanelRenderer.DrawImages(false, true, false);
            obj.Tools.OverlayImageChanged;
            
            notify(obj.ViewerPanel, 'OverlayImageChangedEvent');
        end
        
        function AutoChangeOrientation(obj)
            orientation = obj.ViewerPanel.BackgroundImage.Find2DOrientation;
            if ~isempty(orientation)
                obj.ViewerPanel.Orientation = orientation;
            end
        end
        
        function UpdateGui(obj)
            main_image = obj.ViewerPanel.BackgroundImage;
            obj.Toolbar.UpdateGui(main_image);
            
            if ~isempty(main_image) && main_image.ImageExists
                image_size = main_image.ImageSize;
                if obj.ViewerPanel.SliceNumber(obj.ViewerPanel.Orientation) > image_size(obj.ViewerPanel.Orientation)
                    obj.ViewerPanel.SliceNumber(obj.ViewerPanel.Orientation) = image_size(obj.ViewerPanel.Orientation);
                end
                if obj.ViewerPanel.SliceNumber(obj.ViewerPanel.Orientation) < 1
                    obj.ViewerPanel.SliceNumber(obj.ViewerPanel.Orientation) = 1;
                end
                obj.ViewerPanelRenderer.SetSliceNumber(obj.ViewerPanel.SliceNumber(obj.ViewerPanel.Orientation));
            end
        end
        
        function UpdateGuiForNewImage(obj)
            main_image = obj.ViewerPanel.BackgroundImage;
            if ~isempty(main_image) && main_image.ImageExists
                
                obj.AutoOrientationAndWL(main_image);

                limits = main_image.Limits;
                limits_hu = main_image.GrayscaleToRescaled(limits);
                if ~isempty(limits_hu)
                    limits = limits_hu;
                end

                obj.Toolbar.SetWindowLimits(0, max(1, 3*(limits(2) - limits(1))));
                if obj.ViewerPanel.Window < 0
                    obj.ViewerPanel.Window = 0;
                end
                if obj.ViewerPanel.Window > max(1, limits(2) - limits(1))
                    obj.ViewerPanel.Window = max(1, limits(2) - limits(1));
                end
                
                obj.Toolbar.SetLevelLimits(limits(1), max(limits(1)+1, limits(2)));
                if obj.ViewerPanel.Level < limits(1)
                    obj.ViewerPanel.Level = limits(1);
                end
                if obj.ViewerPanel.Level > limits(2)
                    obj.ViewerPanel.Level = limits(2);
                end
            end
        end
        
        function UpdateGuiForNewOrientation(obj)
            main_image = obj.ViewerPanel.BackgroundImage;
            if ~isempty(main_image) && main_image.ImageExists
                
                image_size = main_image.ImageSize;
                slider_max =  max(2, image_size(obj.ViewerPanel.Orientation));
                slider_min = 1;
                if obj.ViewerPanel.SliceNumber(obj.ViewerPanel.Orientation) > image_size(obj.ViewerPanel.Orientation)
                    obj.ViewerPanel.SliceNumber(obj.ViewerPanel.Orientation) = image_size(obj.ViewerPanel.Orientation);
                end
                if obj.ViewerPanel.SliceNumber(obj.ViewerPanel.Orientation) < 1
                    obj.ViewerPanel.SliceNumber(obj.ViewerPanel.Orientation) = 1;
                end

                obj.ViewerPanelRenderer.SetSliceNumber(obj.ViewerPanel.SliceNumber(obj.ViewerPanel.Orientation));
                obj.ViewerPanelRenderer.SetSliderLimits(slider_min, slider_max);
                obj.ViewerPanelRenderer.SetSliderSteps([1/(slider_max - slider_min), 10/(slider_max-slider_min)]);
            end
        end
        
        function AutoOrientationAndWL(obj, new_image)
            obj.ViewerPanel.Orientation = PTKImageUtilities.GetPreferredOrientation(new_image);
            
            if isa(new_image, 'PTKDicomImage') && new_image.IsCT
                obj.ViewerPanel.Window = 1600;
                obj.ViewerPanel.Level = -600;
            else
                mean_value = round(mean(new_image.RawImage(:)));
                obj.ViewerPanel.Window = mean_value*2;
                obj.ViewerPanel.Level = mean_value;
            end
        end        
        
        function UpdateStatus(obj)
            global_coords = obj.ViewerPanelRenderer.GetImageCoordinates;
            obj.Toolbar.UpdateStatus(global_coords);            
        end
        
    end
end