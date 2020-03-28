Imports WIA

Public Class clsWia


    Private ReadOnly _deviceInfo As DeviceInfo

    Public Sub New(deviceInfo As DeviceInfo)
        Me._deviceInfo = deviceInfo
    End Sub



    Public Sub New()
        'Me._deviceInfo = DeviceInfo
    End Sub

    Public Function Scan() As ImageFile
        ' Connect to the device
        Dim device = Me._deviceInfo.Connect()

        'define dialogo para telas de scan (para scan com barra de progresso)
        'Dim dialog = New CommonDialogClass()

        ' Start the scan
        Dim item = device.Items(1)
        'scan sem barra de progresso
        ''''Dim imageFile = DirectCast(item.Transfer(FormatID.wiaFormatJPEG), ImageFile)

        AdjustScannerSettings(item, 300, 0, 0, 1010, 620, 0, 0)

        'scan com barra de progresso
        'Dim imageFile = TryCast(dialog.ShowTransfer(item, WIA.FormatID.wiaFormatJPEG), WIA.ImageFile)

        ' Return the imageFile
        'Return imageFile
    End Function

    Public Overrides Function ToString() As String
        Return Me._deviceInfo.Properties("Name").Value.ToString '   get_Value().ToString()        
    End Function

    Public Shared Sub SetWIAProperty(properties As IProperties, propName As Object, propValue As Object)
        Dim prop As [Property] = properties.Item(propName)
        prop.Value = propValue
    End Sub

    Public Shared Sub AdjustScannerSettings(ByRef scannnerItem As IItem, scanResolutionDPI As Integer, scanStartLeftPixel As Integer, scanStartTopPixel As Integer, scanWidthPixels As Integer, scanHeightPixels As Integer,
    brightnessPercents As Integer, contrastPercents As Integer)
        Const WIA_HORIZONTAL_SCAN_RESOLUTION_DPI As String = "6147"
        Const WIA_VERTICAL_SCAN_RESOLUTION_DPI As String = "6148"
        Const WIA_HORIZONTAL_SCAN_START_PIXEL As String = "6149"
        Const WIA_VERTICAL_SCAN_START_PIXEL As String = "6150"
        Const WIA_HORIZONTAL_SCAN_SIZE_PIXELS As String = "6151"
        Const WIA_VERTICAL_SCAN_SIZE_PIXELS As String = "6152"
        Const WIA_SCAN_BRIGHTNESS_PERCENTS As String = "6154"
        Const WIA_SCAN_CONTRAST_PERCENTS As String = "6155"

        SetWIAProperty(scannnerItem.Properties, WIA_HORIZONTAL_SCAN_RESOLUTION_DPI, scanResolutionDPI)
        SetWIAProperty(scannnerItem.Properties, WIA_VERTICAL_SCAN_RESOLUTION_DPI, scanResolutionDPI)
        SetWIAProperty(scannnerItem.Properties, WIA_HORIZONTAL_SCAN_START_PIXEL, scanStartLeftPixel)
        SetWIAProperty(scannnerItem.Properties, WIA_VERTICAL_SCAN_START_PIXEL, scanStartTopPixel)
        SetWIAProperty(scannnerItem.Properties, WIA_HORIZONTAL_SCAN_SIZE_PIXELS, scanWidthPixels)
        SetWIAProperty(scannnerItem.Properties, WIA_VERTICAL_SCAN_SIZE_PIXELS, scanHeightPixels)
        SetWIAProperty(scannnerItem.Properties, WIA_SCAN_BRIGHTNESS_PERCENTS, brightnessPercents)
        SetWIAProperty(scannnerItem.Properties, WIA_SCAN_CONTRAST_PERCENTS, contrastPercents)
    End Sub

End Class
