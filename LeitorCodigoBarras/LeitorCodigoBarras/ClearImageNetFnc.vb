Imports System
Imports System.Collections.Generic
Imports System.Text
Imports Inlite.ClearImageNet
Imports System.Drawing
Imports System.IO
Imports System.Threading
Imports ClearImageNet

Friend Class ClearImageNetFnc
    Friend txtRslt As System.Windows.Forms.TextBox = Nothing
    Friend tbrCode As UInteger

    Friend Function readWithZones(ByVal fileName As String, ByVal page As Integer) As String
        Dim reader As BarcodeReader = Nothing
        Try
            reader = New BarcodeReader()
            If tbrCode <> 0 Then reader.TbrCode = tbrCode
            reader.Horizontal = True
            reader.Vertical = True
            reader.Diagonal = True
            reader.Code128 = True
            reader.Code39 = True
            Dim io As ImageIO = New ImageIO()
            Dim info As ImageInfo = io.Info(fileName, page)
            Dim s As String = "======= Barcode in ZONE (upper half of the image) ===========" & Environment.NewLine
            reader.Zone = New Rectangle(0, 0, info.Width, info.Height / 2)
            Dim barcodes As Barcode() = reader.Read(fileName, page)
            Dim cnt As Integer = 0

            For Each bc As Barcode In barcodes
                cnt += 1
                AddBarcode(s, cnt, bc)
            Next

            If cnt = 0 Then
                s = s & "NO BARCODES"
            End If

            s = s & Environment.NewLine
            s = s & "======= Barcode in IMAGE ===========" & Environment.NewLine
            reader.Zone = New Rectangle()
            barcodes = reader.Read(fileName, page)
            cnt = 0

            For Each bc As Barcode In barcodes
                cnt += 1
                AddBarcode(s, cnt, bc)
            Next

            If cnt = 0 Then
                s = s & "NO BARCODES"
            End If

            Return s
        Catch ex As Exception
            Return ex.Message
        Finally
            If reader IsNot Nothing Then reader.Dispose()
        End Try
    End Function

    Private Sub _OnBarcodeFound(ByVal sender As Object, ByVal e As BarcodeFoundEventArgs)
        txtRslt.Text = txtRslt.Text & "_OnBarcodeFound -> "
        Dim s As String = txtRslt.Text
        AddBarcode(s, e.Count, e.Barcode)
        txtRslt.Text = s
        System.Windows.Forms.Application.DoEvents()
    End Sub

    Friend Function readWithEvents(ByVal fileName As String) As String
        Dim reader As BarcodeReader = Nothing

        Try
            reader = New BarcodeReader()
            If tbrCode <> 0 Then reader.TbrCode = tbrCode
            reader.Horizontal = True
            reader.Vertical = True
            reader.Diagonal = True
            reader.Code128 = True
            reader.Code39 = True
            AddHandler reader.BarcodeFoundEvent, AddressOf _OnBarcodeFound
            reader.Read(fileName)

            If (txtRslt.Text = "") Then
                txtRslt.Text = "NO BARCODES"
            End If

            Return ""
        Catch ex As Exception
            Return ex.Message
        Finally
            If reader IsNot Nothing Then reader.Dispose()
        End Try
    End Function

    Private filesScanned As Long = 0
    Shared _lockObject As Object = New Object()
    Private filesToScan As String()
    Private Delegate Sub SetControlPropertyThreadSafeDelegate(ByVal control As System.Windows.Forms.Control, ByVal propertyName As String, ByVal propertyValue As Object)

    Public Shared Sub SetControlPropertyThreadSafe(ByVal control As System.Windows.Forms.Control, ByVal propertyName As String, ByVal propertyValue As Object)
        If control.InvokeRequired Then
            control.Invoke(New SetControlPropertyThreadSafeDelegate(AddressOf SetControlPropertyThreadSafe), New Object() {control, propertyName, propertyValue})
        Else
            control.[GetType]().InvokeMember(propertyName, System.Reflection.BindingFlags.SetProperty, Nothing, control, New Object() {propertyValue})
        End If
    End Sub

    Private Sub _OnBarcodeFoundThread(ByVal sender As Object, ByVal e As BarcodeFoundEventArgs)
        SyncLock _lockObject
            Dim s As String = txtRslt.Text & "_OnBarcodeFound on Managed Thread " + System.Threading.Thread.CurrentThread.ManagedThreadId & " -> "
            AddBarcode(s, e.Count, e.Barcode)
            SetControlPropertyThreadSafe(txtRslt, "Text", s)
            System.Windows.Forms.Application.DoEvents()
        End SyncLock
    End Sub

    Private Sub readFileOnThread()
        Dim reader As BarcodeReader = Nothing

        Try
            reader = New BarcodeReader()
            If tbrCode <> 0 Then reader.TbrCode = tbrCode
            reader.Horizontal = True
            reader.Vertical = True
            reader.Diagonal = True
            reader.Code128 = True
            reader.Code39 = True
            AddHandler reader.BarcodeFoundEvent, AddressOf _OnBarcodeFoundThread

            While True
                Dim fileName As String

                SyncLock _lockObject
                    If filesScanned >= filesToScan.Length Then Exit While
                    fileName = filesToScan(filesScanned)
                    filesScanned += 1
                End SyncLock

                Try
                    reader.Read(fileName, 1)
                Catch ex As Exception
                    Dim s As String = txtRslt.Text & ">>>>>>>> ERROR processing '" & fileName & "'" & Environment.NewLine & ex.Message & Environment.NewLine

                    SyncLock _lockObject
                        SetControlPropertyThreadSafe(txtRslt, "Text", s)
                        System.Windows.Forms.Application.DoEvents()
                    End SyncLock
                End Try
            End While

        Catch ex As Exception
            Dim s As String = txtRslt.Text & ">>>>>>>> ERROR processing '" & Environment.NewLine & ex.Message & Environment.NewLine

            SyncLock _lockObject
                SetControlPropertyThreadSafe(txtRslt, "Text", s)
                System.Windows.Forms.Application.DoEvents()
            End SyncLock

        Finally
            If reader IsNot Nothing Then reader.Dispose()
        End Try
    End Sub

    Friend Function readDirectoryWithThreads(ByVal directoryName As String) As String
        filesToScan = Directory.GetFiles(directoryName, "*.*", SearchOption.TopDirectoryOnly)
        filesScanned = 0
        Dim workerThread1 As Thread = New Thread(New ThreadStart(AddressOf readFileOnThread))
        workerThread1.Start()
        Dim workerThread2 As Thread = New Thread(New ThreadStart(AddressOf readFileOnThread))
        workerThread2.Start()

        While workerThread1.IsAlive OrElse workerThread2.IsAlive
            System.Windows.Forms.Application.DoEvents()
        End While

        txtRslt.Text = txtRslt.Text & "DONE!!!"
        Return ""
    End Function

    Friend Function readCode128andCode39(ByVal fileName As String, ByVal page As Integer) As String
        Dim reader As BarcodeReader = Nothing

        Try
            reader = New BarcodeReader()
            If tbrCode <> 0 Then reader.TbrCode = tbrCode
            reader.Horizontal = True
            reader.Vertical = True
            reader.Diagonal = True
            reader.Code128 = True
            reader.Code39 = True
            Dim barcodes As Barcode() = reader.Read(fileName, page)
            Dim s As String = ""
            Dim cnt As Integer = 0

            For Each bc As Barcode In barcodes
                cnt += 1
                AddBarcode(s, cnt, bc)
            Next

            If cnt = 0 Then
                s = s & "NO BARCODES"
            End If

            s = s & Environment.NewLine
            Return s
        Catch ex As Exception
            Return ex.Message
        Finally
            If reader IsNot Nothing Then reader.Dispose()
        End Try
    End Function


    Friend Function read1DautoType(ByVal bmp As Bitmap) As String
        Dim reader As BarcodeReader = Nothing

        Try
            reader = New BarcodeReader()
            If tbrCode <> 0 Then reader.TbrCode = tbrCode
            reader.Horizontal = True
            reader.Vertical = True
            reader.Diagonal = True
            reader.Auto1D = True
            Dim barcodes As Barcode() = reader.Read(bmp)
            Dim s As String = ""
            Dim cnt As Integer = 0

            For Each bc As Barcode In barcodes
                cnt += 1
                AddBarcode(s, cnt, bc)
            Next

            If cnt = 0 Then
                s = s & "NO BARCODES"
            End If

            s = s & Environment.NewLine
            Return s
        Catch ex As Exception
            Return ex.Message
        Finally
            If reader IsNot Nothing Then reader.Dispose()
        End Try
    End Function



    Friend Function read1DautoType(ByVal fileName As String, ByVal page As Integer) As String
        Dim reader As BarcodeReader = Nothing

        Try
            reader = New BarcodeReader()
            If tbrCode <> 0 Then reader.TbrCode = tbrCode
            reader.Horizontal = True
            reader.Vertical = True
            reader.Diagonal = True
            reader.Auto1D = True
            Dim barcodes As Barcode() = reader.Read(fileName, page)
            Dim s As String = ""
            Dim cnt As Integer = 0

            For Each bc As Barcode In barcodes
                cnt += 1
                AddBarcode(s, cnt, bc)
            Next

            If cnt = 0 Then
                s = s & "NO BARCODES"
            End If

            s = s & Environment.NewLine
            Return s
        Catch ex As Exception
            Return ex.Message
        Finally
            If reader IsNot Nothing Then reader.Dispose()
        End Try
    End Function

    Friend Function readMultiPageFile(ByVal fileName As String) As String
        Dim reader As BarcodeReader = Nothing

        Try
            reader = New BarcodeReader()
            If tbrCode <> 0 Then reader.TbrCode = tbrCode
            reader.Horizontal = True
            reader.Vertical = True
            reader.Diagonal = True
            reader.Code128 = True
            reader.Code39 = True
            Dim barcodes As Barcode() = reader.Read(fileName)
            Dim s As String = ""
            Dim cnt As Integer = 0

            For Each bc As Barcode In barcodes
                cnt += 1
                AddBarcode(s, cnt, bc)
            Next

            If cnt = 0 Then
                s = s & "NO BARCODES"
            End If

            s = s & Environment.NewLine
            Return s
        Catch ex As Exception
            Return ex.Message
        Finally
            If reader IsNot Nothing Then reader.Dispose()
        End Try
    End Function

    'Friend Function readFromStream(ByVal fileName As String) As String
    '    Dim reader As BarcodeReader = Nothing

    '    Try
    '        reader = New BarcodeReader()
    '        If tbrCode <> 0 Then reader.TbrCode = tbrCode
    '        reader.Horizontal = True
    '        reader.Vertical = True
    '        reader.Diagonal = True
    '        reader.Code128 = True
    '        reader.Code39 = True
    '        Dim s As String = ""

    '        Using ms As MemoryStream = Utility.FileToStream(fileName)
    '            Dim barcodes As Barcode() = reader.Read(ms)
    '            Dim cnt As Integer = 0

    '            For Each bc As Barcode In barcodes
    '                cnt += 1
    '                AddBarcode(s, cnt, bc)
    '            Next

    '            If cnt = 0 Then
    '                s = s & "NO BARCODES"
    '            End If
    '        End Using

    '        s = s & Environment.NewLine
    '        Return s
    '    Catch ex As Exception
    '        Return ex.Message
    '    Finally
    '        If reader IsNot Nothing Then reader.Dispose()
    '    End Try
    'End Function

    Friend Function readPDF417(ByVal fileName As String, ByVal page As Integer) As String
        Dim reader As BarcodeReader = Nothing

        Try
            reader = New BarcodeReader()
            If tbrCode <> 0 Then reader.TbrCode = tbrCode
            reader.Horizontal = True
            reader.Vertical = True
            reader.Diagonal = True
            reader.Pdf417 = True
            Dim barcodes As Barcode() = reader.Read(fileName, page)
            Dim s As String = ""
            Dim cnt As Integer = 0

            For Each bc As Barcode In barcodes
                cnt += 1
                AddBarcode(s, cnt, bc)
            Next

            If cnt = 0 Then
                s = "NO BARCODES"
            End If

            Return s
        Catch ex As Exception
            Return ex.Message
        Finally
            If reader IsNot Nothing Then reader.Dispose()
        End Try
    End Function

    Friend Function readDriverLicense(ByVal fileName As String, ByVal page As Integer) As String
        Dim reader As BarcodeReader = Nothing

        Try
            reader = New BarcodeReader()
            If tbrCode <> 0 Then reader.TbrCode = tbrCode
            reader.Horizontal = True
            reader.Vertical = True
            reader.Diagonal = True
            reader.DrvLicID = True
            Dim barcodes As Barcode() = reader.Read(fileName, page)
            Dim s As String = ""
            Dim cnt As Integer = 0

            For Each bc As Barcode In barcodes
                cnt += 1

                If bc.Type = BarcodeType.Pdf417 Then
                    Dim aamva As String = bc.Decode(BarcodeDecoding.aamva)
                    If aamva <> "" Then s = s & "Driver License / ID Data: " & Environment.NewLine & aamva & Environment.NewLine
                End If

                AddBarcode(s, cnt, bc)
            Next

            If cnt = 0 Then
                s = "NO BARCODES"
            End If

            Return s
        Catch ex As Exception
            Return ex.Message
        Finally
            If reader IsNot Nothing Then reader.Dispose()
        End Try
    End Function

    Friend Function readDataMatrix(ByVal fileName As String, ByVal page As Integer) As String
        Dim reader As BarcodeReader = Nothing

        Try
            reader = New BarcodeReader()
            If tbrCode <> 0 Then reader.TbrCode = tbrCode
            reader.Horizontal = True
            reader.Vertical = True
            reader.Diagonal = True
            reader.DataMatrix = True
            Dim barcodes As Barcode() = reader.Read(fileName, page)
            Dim s As String = ""
            Dim cnt As Integer = 0

            For Each bc As Barcode In barcodes
                cnt += 1
                AddBarcode(s, cnt, bc)
            Next

            If cnt = 0 Then
                s = "NO BARCODES"
            End If

            Return s
        Catch ex As Exception
            Return ex.Message
        Finally
            If reader IsNot Nothing Then reader.Dispose()
        End Try
    End Function

    Friend Function readQR(ByVal fileName As String, ByVal page As Integer) As String
        Dim reader As BarcodeReader = Nothing

        Try
            reader = New BarcodeReader()
            If tbrCode <> 0 Then reader.TbrCode = tbrCode
            reader.Horizontal = True
            reader.Vertical = True
            reader.Diagonal = True
            reader.QR = True
            Dim barcodes As Barcode() = reader.Read(fileName, page)
            Dim s As String = ""
            Dim cnt As Integer = 0

            For Each bc As Barcode In barcodes
                cnt += 1
                AddBarcode(s, cnt, bc)
            Next

            If cnt = 0 Then
                s = "NO BARCODES"
            End If

            Return s
        Catch ex As Exception
            Return ex.Message
        Finally
            If reader IsNot Nothing Then reader.Dispose()
        End Try
    End Function

    Friend Function ShowInfo(ByVal info As ImageInfo, ByVal nPage As Integer) As String
        Dim s As String = ""
        If nPage = 1 Then s += "File = " & info.FileName & Environment.NewLine & "  PageCnt = " + info.PageCount.ToString() & "   Format = " & System.[Enum].GetName(GetType(ImageFileFormat), info.FileFormat) & Environment.NewLine

        If info.Page > 0 Then
            s = s & "  Page=" & info.Page.ToString() & "  Format=" & System.[Enum].GetName(GetType(PageCompression), info.Compression) & "  Size=" + info.Width.ToString() & "x" + info.Height.ToString() & "  Dpi=" + info.HorizontalDpi.ToString() & "x" + info.VerticalDpi.ToString() & "  Bpp=" + info.BitsPerPixel.ToString() & Environment.NewLine
        Else
            s = s & "  Page = " & nPage.ToString() & "   Format = " & System.[Enum].GetName(GetType(PageCompression), info.Compression) & Environment.NewLine
        End If

        Return s
    End Function

    Friend Function Info(ByVal fileName As String) As String
        Dim s As String = ""
        Dim io1 As ImageIO = New ImageIO()
        Dim page As Integer = 1
        Dim oInfo As ImageInfo
        oInfo = io1.Info(fileName, page)
        Dim pages As Integer = oInfo.PageCount
        txtRslt.Text = txtRslt.Text & ShowInfo(oInfo, page)

        For page = 2 To Math.Min(pages, 20)
            oInfo = io1.Info(fileName, page)
            txtRslt.Text = txtRslt.Text & ShowInfo(oInfo, page)
            System.Windows.Forms.Application.DoEvents()
        Next

        Return txtRslt.Text
    End Function

    Friend Function repairPage(ByVal fileName As String, ByVal page As Integer, ByVal fileOut As String, ByVal format As ImageFileFormat) As String
        Dim editor As ImageEditor = Nothing

        Try
            editor = New ImageEditor()
            editor.Image.Open(fileName, page)
            Dim s As String = "File:" & fileName & "  Page:" & page.ToString() & Environment.NewLine
            editor.AutoDeskew()
            s = s & "AutoDeskew" & Environment.NewLine
            editor.AutoCrop(50, 50, 50, 50)
            s = s & "AutoCrop (margins 50pix)" & Environment.NewLine

            If fileOut <> "" Then

                If File.Exists(fileOut) Then
                    editor.Image.Append(fileOut, Inlite.ClearImage.EFileFormat.ciEXT)
                    s = s & "Append:" & fileOut
                Else
                    editor.Image.SaveAs(fileOut, Inlite.ClearImage.EFileFormat.ciEXT)
                    s = s & "SaveAs:" & fileOut
                End If
            End If

            s = s & Environment.NewLine & "--------------" & Environment.NewLine
            Return s
        Catch ex As Exception
            Return ex.Message
        Finally
            If editor IsNot Nothing Then editor.Dispose()
        End Try
    End Function

    Private Sub _OnEditPage(ByVal sender As Object, ByVal e As EditPageEventArgs)
        e.Editor.AutoDeskew()
        e.Editor.AutoCrop(50, 50, 50, 50)
        Dim s As String = "_OnEditPage -> "
        s = s & "File:" & e.Editor.Image.FileName & "  Page:" + e.Editor.Image.PageNumber & Environment.NewLine
        s = s & "AutoDeskew" & Environment.NewLine
        s = s & "AutoCrop (margins 50pix)" & Environment.NewLine
        txtRslt.Text = txtRslt.Text & s
        System.Windows.Forms.Application.DoEvents()
    End Sub

    Friend Function repairFile(ByVal fileName As String, ByVal fileOut As String, ByVal format As ImageFileFormat) As String
        Dim editor As ImageEditor = Nothing

        Try
            editor = New ImageEditor()
            Dim ret As Boolean = editor.Edit(fileName, AddressOf _OnEditPage, fileOut, format, True)
            Return txtRslt.Text
        Catch ex As Exception
            Return ex.Message
        Finally
            If editor IsNot Nothing Then editor.Dispose()
        End Try
    End Function

    'Friend Function repairStream(ByVal fileName As String, ByVal fileOut As String, ByVal format As ImageFileFormat) As String
    '    Dim editor As ImageEditor = Nothing

    '    Try
    '        editor = New ImageEditor()
    '        Dim ms As MemoryStream = Utility.FileToStream(fileName)
    '        Dim msOut As MemoryStream = editor.Edit(ms, AddressOf _OnEditPage, format)
    '        If msOut IsNot Nothing Then Utility.StreamToFile(msOut, fileOut)
    '        Return ""
    '    Catch ex As Exception
    '        Return ex.Message
    '    Finally
    '        If editor IsNot Nothing Then editor.Dispose()
    '    End Try
    'End Function

    Friend Function toolsPage(ByVal fileName As String, ByVal page As Integer) As String
        Dim editor As ImageEditor = Nothing

        Try
            editor = New ImageEditor()
            Dim s As String = ""
            editor.Image.Open(fileName, page)
            Dim dSkew As Double = editor.SkewAngle
            s = s & String.Format("Skew {0:0.##} deg", dSkew) & Environment.NewLine

            If editor.BitsPerPixel = 1 Then
                Dim objects As ImageObject() = editor.GetObjects()
                s = s & String.Format("Object Count: {0}", objects.Length) & Environment.NewLine
            End If

            Return s
        Catch ex As Exception
            Return ex.Message
        Finally
            If editor IsNot Nothing Then editor.Dispose()
        End Try
    End Function

    Friend Function serverInfo() As String
        txtRslt.Text = txtRslt.Text & "ClearImageNet Server " + Server.Major.ToString() & "." + Server.Minor.ToString() & "." + Server.Release.ToString() & "  " + Server.Edition
        txtRslt.Text = txtRslt.Text & Environment.NewLine
        Dim sFormat As String = "{0,-16} {1,-30} {2,-9} {3,-5}"
        Dim s1 As String = String.Format(sFormat, "MODULE", "PRODUCT", "LICENSED", "CALLS")
        txtRslt.Text = txtRslt.Text & s1 & Environment.NewLine

        For Each oModule As LicModule In Server.Modules
            s1 = String.Format(sFormat, oModule.Name, oModule.Product, (If(Server.Edition.StartsWith("Dev"), "DevMode", oModule.IsLicensed.ToString())), oModule.Calls.ToString())
            txtRslt.Text = txtRslt.Text & s1 & Environment.NewLine
        Next

        Return txtRslt.Text
    End Function

    Private Sub _OnObjectFound(ByVal sender As Object, ByVal e As ObjectFoundEventArgs)
        e.cancel = (e.Count = 20)
        txtRslt.Text = txtRslt.Text & "_OnObjectFound -> "
        Dim s As String = txtRslt.Text
        AddObject(s, e.Count, e.ImageObject)
        txtRslt.Text = s
        System.Windows.Forms.Application.DoEvents()
    End Sub

    Friend Function toolsWithEvents(ByVal fileName As String, ByVal page As Integer, ByVal bSaveResults As Boolean) As String
        Dim editor As ImageEditor = Nothing

        Try
            editor = New ImageEditor()
            editor.Image.Open(fileName, page)
            AddHandler editor.ObjectFoundEvent, AddressOf _OnObjectFound
            editor.GetObjects()
            Return txtRslt.Text
        Catch ex As Exception
            Return ex.Message
        Finally
            If editor IsNot Nothing Then editor.Dispose()
        End Try
    End Function

    Private Sub AddBarcode(ByRef s As String, ByVal i As Long, ByVal Bc As Barcode)
        's = s & "Barcode#:" & i.ToString()
        'If Bc.File <> "" Then s += "  File:" & Bc.File
        's = s & " Page:" & Bc.Page.ToString() & Environment.NewLine
        's = s & " Type:" & System.[Enum].GetName(Bc.Type.[GetType](), Bc.Type)
        's = s & " Lng:" & Bc.Length.ToString()
        's = s & " Rect:" & Bc.Rectangle.Left.ToString() & ":" + Bc.Rectangle.Top.ToString() & "-" + Bc.Rectangle.Right.ToString() & ":" + Bc.Rectangle.Bottom.ToString()
        's = s & " Rotation:" & System.[Enum].GetName(Bc.Rotation.[GetType](), Bc.Rotation)

        'If Bc.Type = BarcodeType.Pdf417 OrElse Bc.Type = BarcodeType.DataMatrix OrElse Bc.Type = BarcodeType.QR Then
        '    Dim decomp As String = Bc.Decode(BarcodeDecoding.compA)
        '    If decomp <> "" Then s = s & Environment.NewLine & Environment.NewLine & "DECOMPRESSED BARCODE DATA (A):" & Environment.NewLine & decomp & Environment.NewLine
        '    decomp = Bc.Decode(BarcodeDecoding.compI)
        '    If decomp <> "" Then s = s & Environment.NewLine & Environment.NewLine & "DECOMPRESSED BARCODE DATA (I):" & Environment.NewLine & decomp & Environment.NewLine
        'End If

        's = s & Environment.NewLine & "RAW BARCODE DATA:" & Environment.NewLine & Bc.Text
        's = s & Environment.NewLine & "--------------" & Environment.NewLine

        s = Bc.Text
    End Sub

    Private Sub AddObject(ByRef s As String, ByVal cnt As Long, ByVal Obj As ImageObject)
        s = s & "Object #" & cnt.ToString()
        s = s & " Pixels:" & Obj.Pixels.ToString() & " Intervals:" + Obj.Intervals.ToString()
        s = s & " Rect:" & Obj.Rectangle.Left.ToString() & ":" + Obj.Rectangle.Top.ToString() & "-" + Obj.Rectangle.Right.ToString() & ":" + Obj.Rectangle.Bottom.ToString()
        s = s & Environment.NewLine
    End Sub
End Class

