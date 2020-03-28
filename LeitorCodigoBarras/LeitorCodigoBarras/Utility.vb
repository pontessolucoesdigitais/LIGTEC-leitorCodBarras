Imports System.Collections.Generic
Imports System.Text
Imports System.IO

Class Utility
    Friend Shared Function FileToStream(ByVal fileName As String) As MemoryStream
        ' Convert file to stream
        Dim fs As FileStream = File.OpenRead(fileName)
        Dim b As Byte() = New Byte(fs.Length - 1) {}
        fs.Read(b, 0, b.Length)
        fs.Close()
        Dim ms As New MemoryStream(b)
        Return ms
    End Function

    Friend Shared Sub StreamToFile(ByVal stream As Stream, ByVal fileOut As String)
        Dim buffer As Byte() = New Byte(255) {}
        Dim fileStream As New FileStream(fileOut, FileMode.Create, FileAccess.Write)
        Dim bytesRead As Integer = stream.Read(buffer, 0, 256)
        While bytesRead > 0
            fileStream.Write(buffer, 0, bytesRead)
            bytesRead = stream.Read(buffer, 0, 256)
        End While
        stream.Close()
        fileStream.Close()
    End Sub
End Class

Class WIA_CONSTs
    Public Const DeviceID = 2
    Public Const Manufacturer = 3
    Public Const Description = 4
    Public Const Type = 5
    Public Const Port = 6
    Public Const Name = 7
    Public Const Server = 8
    Public Const RemoteDevID = 9
    Public Const UIClassID = 10
    Public Const FirmwareVersion = 1026
    Public Const ConnectStatus = 1027
    Public Const DeviceTime = 1028
    Public Const PicturesTaken = 2050
    Public Const PicturesRemaining = 2051
    Public Const ExposureMode = 2052
    Public Const ExposureCompensation = 2053
    Public Const ExposureTime = 2054
    Public Const FNumber = 2055
    Public Const FlashMode = 2056
    Public Const FocusMode = 2057
    Public Const FocusManualDist = 2058
    Public Const ZoomPosition = 2059
    Public Const PanPosition = 2060
    Public Const TiltPostion = 2061
    Public Const TimerMode = 2062
    Public Const TimerValue = 2063
    Public Const PowerMode = 2064
    Public Const BatteryStatus = 2065
    Public Const Dimension = 2070
    Public Const HorizontalBedSize = 3074
    Public Const VerticalBedSize = 3075
    Public Const HorizontalSheetFeedSize = 3076
    Public Const VerticalSheetFeedSize = 3077
    Public Const SheetFeederRegistration = 3078
    Public Const HorizontalBedRegistration = 3079
    Public Const VerticalBedRegistraion = 3080
    Public Const PlatenColor = 3081
    Public Const PadColor = 3082
    Public Const FilterSelect = 3083
    Public Const DitherSelect = 3084
    Public Const DitherPatternData = 3085
    Public Const DocumentHandlingCapabilities = 3086
    Public Const DocumentHandlingStatus = 3087
    Public Const DocumentHandlingSelect = 3088
    Public Const DocumentHandlingCapacity = 3089
    Public Const HorizontalOpticalResolution = 3090
    Public Const VerticalOpticalResolution = 3091
    Public Const EndorserCharacters = 3092
    Public Const EndorserString = 3093
    Public Const ScanAheadPages = 3094
    Public Const MaxScanTime = 3095
    Public Const Pages = 3096
    Public Const PageSize = 3097
    Public Const PageWidth = 3098
    Public Const PageHeight = 3099
    Public Const Preview = 3100
    Public Const TransparencyAdapter = 3101
    Public Const TransparecnyAdapterSelect = 3102
    Public Const ItemName = 4098
    Public Const FullItemName = 4099
    Public Const ItemTimeStamp = 4100
    Public Const ItemFlags = 4101
    Public Const AccessRights = 4102
    Public Const DataType = 4103
    Public Const BitsPerPixel = 4104
    Public Const PreferredFormat = 4105
    Public Const Format = 4106
    Public Const Compression = 4107
    Public Const MediaType = 4108
    Public Const ChannelsPerPixel = 4109
    Public Const BitsPerChannel = 4110
    Public Const Planar = 4111
    Public Const PixelsPerLine = 4112
    Public Const BytesPerLine = 4113
    Public Const NumberOfLines = 4114
    Public Const GammaCurves = 4115
    Public Const ItemSize = 4116
    Public Const ColorProfiles = 4117
    Public Const BufferSize = 4118
    Public Const RegionType = 4119
    Public Const ColorProfileName = 4120
    Public Const ApplicationAppliesColorMapping = 4121
    Public Const StreamCompatibilityID = 4122
    Public Const ThumbData = 5122
    Public Const ThumbWidth = 5123
    Public Const ThumbHeight = 5124
    Public Const AudioAvailable = 5125
    Public Const AudioFormat = 5126
    Public Const AudioData = 5127
    Public Const PicturesPerRow = 5128
    Public Const SequenceNumber = 5129
    Public Const TimeDelay = 5130
    Public Const CurrentIntent = 6146
    Public Const HorizontalResolution = 6147
    Public Const VerticalResolution = 6148
    Public Const HorizontalStartPostion = 6149
    Public Const VerticalStartPosition = 6150
    Public Const HorizontalExtent = 6151
    Public Const VerticalExtent = 6152
    Public Const PhotometricInterpretation = 6153
    Public Const Brightness = 6154
    Public Const Contrast = 6155
    Public Const Orientation = 6156
    Public Const Rotation = 6157
    Public Const Mirror = 6158
    Public Const Threshold = 6159
    Public Const Invert = 6160
    Public Const LampWarmUpTime = 6161

    Public Const wiaFormatBMP = "{B96B3CAB-0728-11D3-9D7B-0000F81EF32E}"
    Public Const wiaFormatPNG = "{B96B3CAF-0728-11D3-9D7B-0000F81EF32E}"
    Public Const wiaFormatGIF = "{B96B3CB0-0728-11D3-9D7B-0000F81EF32E}"
    Public Const wiaFormatJPEG = "{B96B3CAE-0728-11D3-9D7B-0000F81EF32E}"
    Public Const wiaFormatTIFF = "{B96B3CB1-0728-11D3-9D7B-0000F81EF32E}"

End Class



