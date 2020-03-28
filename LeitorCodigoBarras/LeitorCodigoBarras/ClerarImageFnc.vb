Imports System
Imports System.Collections.Generic
Imports System.Text
Imports Inlite.ClearImage
Imports Inlite.ClearImageNet
Imports System.Drawing
Imports System.IO
Imports System.Threading

Friend Class ClearImageFnc
    Friend txtRslt As System.Windows.Forms.TextBox = Nothing
    Friend tbrCode As UInteger

    Friend Function readWithZones(ByVal fileName As String, ByVal page As Integer) As String
        Dim reader As CiBarcodePro = Nothing

        Try
            Dim ci As CiServer = Inlite.ClearImageNet.Server.GetThreadServer()
            reader = ci.CreateBarcodePro()
            If tbrCode <> 0 Then reader.TbrCode = tbrCode
            reader.Directions = FBarcodeDirections.cibHorz Or FBarcodeDirections.cibVert Or FBarcodeDirections.cibDiag
            reader.Type = FBarcodeType.cibfCode128 Or FBarcodeType.cibfCode39
            Dim image As CiImage = ci.CreateImage()
            Dim st As String = image.FileName
            image.Open(fileName, page)
            Dim s As String = "======= Barcode in ZONE (upper half of the image) ===========" & Environment.NewLine
            reader.Image = image.CreateZone(0, 0, image.Width, image.Height / 2)
            reader.Find(0)
            Dim cnt As Integer = 0

            For Each bc As CiBarcode In reader.Barcodes
                cnt += 1
                AddBarcode(s, cnt, bc, image.FileName, image.PageNumber)
            Next

            If cnt = 0 Then
                s = s & "NO BARCODES"
            End If

            s = s & Environment.NewLine
            s = s & "======= Barcode in IMAGE ===========" & Environment.NewLine
            reader.Image = image
            reader.Find(0)
            cnt = 0

            For Each bc As CiBarcode In reader.Barcodes
                cnt += 1
                AddBarcode(s, cnt, bc, image.FileName, image.PageNumber)
            Next

            If cnt = 0 Then
                s = s & "NO BARCODES"
            End If

            s = s & Environment.NewLine
            Return s
        Catch ex As Exception
            Return ex.Message
        Finally
            If reader IsNot Nothing Then reader.Image.Close()
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

    Private Sub Read1DPro_OnThread()
        Dim reader As CiBarcodePro = Nothing

        Try
            Dim ci As CiServer = Inlite.ClearImageNet.Server.GetThreadServer()
            reader = ci.CreateBarcodePro()
            If tbrCode <> 0 Then reader.TbrCode = tbrCode
            reader.Directions = FBarcodeDirections.cibHorz Or FBarcodeDirections.cibVert Or FBarcodeDirections.cibDiag
            reader.Type = FBarcodeType.cibfCode128 Or FBarcodeType.cibfCode39

            While True
                Dim fileName As String

                SyncLock _lockObject
                    If filesScanned >= filesToScan.Length Then Exit While
                    fileName = filesToScan(filesScanned)
                    filesScanned += 1
                End SyncLock

                Dim s As String = ""

                Try
                    Dim page As Integer = 1
                    reader.Image.Open(fileName, 1)

                    While reader.Image.IsValid
                        reader.Find(0)
                        Dim cnt As Integer = 0

                        For Each bc As CiBarcode In reader.Barcodes
                            cnt += 1
                            AddBarcode(s, cnt, bc, reader.Image.FileName, page)
                        Next

                        page += 1
                        If page > reader.Image.PageCount Then Exit While
                        reader.Image.Open(fileName, page)
                    End While

                    SyncLock _lockObject

                        If s <> "" Then
                            Dim s1 As String = txtRslt.Text & "_OnBarcodeFound on Managed Thread " + System.Threading.Thread.CurrentThread.ManagedThreadId & " -> " & Environment.NewLine & s
                            SetControlPropertyThreadSafe(txtRslt, "Text", s)
                        End If

                        System.Windows.Forms.Application.DoEvents()
                    End SyncLock

                Catch ex As Exception
                    Dim s1 As String = txtRslt.Text & ">>>>>>>> ERROR processing '" & fileName & "'" & Environment.NewLine & ex.Message & Environment.NewLine

                    SyncLock _lockObject
                        SetControlPropertyThreadSafe(txtRslt, "Text", s1)
                        System.Windows.Forms.Application.DoEvents()
                    End SyncLock
                End Try
            End While

        Catch ex As Exception
            Dim s1 As String = txtRslt.Text & ">>>>>>>> ERROR processing '" & Environment.NewLine & ex.Message & Environment.NewLine

            SyncLock _lockObject
                SetControlPropertyThreadSafe(txtRslt, "Text", s1)
                System.Windows.Forms.Application.DoEvents()
            End SyncLock

        Finally
            If reader IsNot Nothing Then reader.Image.Close()
        End Try
    End Sub

    Friend Function readDirectoryWithThreads(ByVal directoryName As String) As String
        filesToScan = Directory.GetFiles(directoryName, "*.*", SearchOption.TopDirectoryOnly)
        filesScanned = 0
        Dim workerThread1 As Thread = New Thread(New ThreadStart(AddressOf Read1DPro_OnThread))
        workerThread1.Start()
        Dim workerThread2 As Thread = New Thread(New ThreadStart(AddressOf Read1DPro_OnThread))
        workerThread2.Start()

        While workerThread1.IsAlive OrElse workerThread2.IsAlive
            System.Windows.Forms.Application.DoEvents()
        End While

        txtRslt.Text = txtRslt.Text & "DONE!!!"
        Return ""
    End Function

    Friend Function readCode128andCode39(ByVal fileName As String, ByVal page As Integer) As String
        Dim reader As CiBarcodePro = Nothing

        Try
            Dim ci As CiServer = Inlite.ClearImageNet.Server.GetThreadServer()
            reader = ci.CreateBarcodePro()
            If tbrCode <> 0 Then reader.TbrCode = tbrCode
            reader.Directions = FBarcodeDirections.cibHorz Or FBarcodeDirections.cibVert Or FBarcodeDirections.cibDiag
            reader.Type = FBarcodeType.cibfCode128 Or FBarcodeType.cibfCode39
            reader.Image.Open(fileName, page)
            reader.Find(0)
            Dim cnt As Integer = 0
            Dim s As String = ""

            For Each bc As CiBarcode In reader.Barcodes
                cnt += 1
                AddBarcode(s, cnt, bc, reader.Image.FileName, reader.Image.PageNumber)
            Next

            If cnt = 0 Then
                s = s & "NO BARCODES"
            End If

            s = s & Environment.NewLine
            Return s
        Catch ex As Exception
            Return ex.Message
        Finally
            If reader IsNot Nothing Then reader.Image.Close()
        End Try
    End Function

    Friend Function read1DautoType(ByVal fileName As String, ByVal page As Integer) As String
        Dim reader As CiBarcodePro = Nothing

        Try
            Dim ci As CiServer = Inlite.ClearImageNet.Server.GetThreadServer()
            reader = ci.CreateBarcodePro()
            If tbrCode <> 0 Then reader.TbrCode = tbrCode
            reader.Directions = FBarcodeDirections.cibHorz Or FBarcodeDirections.cibVert Or FBarcodeDirections.cibDiag
            reader.AutoDetect1D = True
            reader.Image.Open(fileName, page)
            reader.Find(0)
            Dim cnt As Integer = 0
            Dim s As String = ""

            For Each bc As CiBarcode In reader.Barcodes
                cnt += 1
                AddBarcode(s, cnt, bc, reader.Image.FileName, reader.Image.PageNumber)
            Next

            If cnt = 0 Then
                s = s & "NO BARCODES"
            End If

            s = s & Environment.NewLine
            Return s
        Catch ex As Exception
            Return ex.Message
        Finally
            If reader IsNot Nothing Then reader.Image.Close()
        End Try
    End Function

    Friend Function readMultiPageFile(ByVal fileName As String) As String
        Dim reader As CiBarcodePro = Nothing

        Try
            Dim ci As CiServer = Inlite.ClearImageNet.Server.GetThreadServer()
            reader = ci.CreateBarcodePro()
            If tbrCode <> 0 Then reader.TbrCode = tbrCode
            reader.Directions = FBarcodeDirections.cibHorz Or FBarcodeDirections.cibVert Or FBarcodeDirections.cibDiag
            reader.Type = FBarcodeType.cibfCode128 Or FBarcodeType.cibfCode39
            Dim s As String = ""
            Dim page As Integer = 1
            reader.Image.Open(fileName, 1)
            Dim cnt As Integer = 0

            While reader.Image.IsValid
                reader.Find(0)

                For Each bc As CiBarcode In reader.Barcodes
                    cnt += 1
                    AddBarcode(s, cnt, bc, reader.Image.FileName, page)
                Next

                page += 1
                If page > reader.Image.PageCount Then Exit While
                reader.Image.Open(fileName, page)
            End While

            If cnt = 0 Then
                s = s & "NO BARCODES"
            End If

            s = s & Environment.NewLine
            Return s
        Catch ex As Exception
            Return ex.Message
        Finally
            If reader IsNot Nothing Then reader.Image.Close()
        End Try
    End Function

    Friend Function readFromStream(ByVal fileName As String) As String
        Dim reader As CiBarcodePro = Nothing

        Try
            Dim ci As CiServer = Inlite.ClearImageNet.Server.GetThreadServer()
            reader = ci.CreateBarcodePro()
            If tbrCode <> 0 Then reader.TbrCode = tbrCode
            reader.Directions = FBarcodeDirections.cibHorz Or FBarcodeDirections.cibVert Or FBarcodeDirections.cibDiag
            reader.Type = FBarcodeType.cibfCode128 Or FBarcodeType.cibfCode39

            Using ms As MemoryStream = Utility.FileToStream(fileName)
                Dim page As Integer = 1
                reader.Image.Open(ms, 1)
                Dim cnt As Integer = 0
                Dim s As String = ""

                While reader.Image.IsValid
                    reader.Find(0)

                    For Each bc As CiBarcode In reader.Barcodes
                        cnt += 1
                        AddBarcode(s, cnt, bc, reader.Image.FileName, page)
                    Next

                    page += 1
                    If page > reader.Image.PageCount Then Exit While
                    reader.Image.OpenPage(page)

                    If cnt = 0 Then
                        s = s & "NO BARCODES"
                    End If

                    s = s & Environment.NewLine
                End While

                Return s
            End Using

        Catch ex As Exception
            Return ex.Message
        Finally
            If reader IsNot Nothing Then reader.Image.Close()
        End Try
    End Function

    Friend Function readPDF417(ByVal fileName As String, ByVal page As Integer) As String
        Dim reader As CiPdf417 = Nothing

        Try
            Dim ci As CiServer = Inlite.ClearImageNet.Server.GetThreadServer()
            reader = ci.CreatePdf417()
            If tbrCode <> 0 Then reader.TbrCode = tbrCode
            reader.Directions = FBarcodeDirections.cibHorz Or FBarcodeDirections.cibVert Or FBarcodeDirections.cibDiag
            reader.Image.Open(fileName, page)
            reader.Find(0)
            Dim cnt As Integer = 0
            Dim s As String = ""

            For Each bc As CiBarcode In reader.Barcodes
                cnt += 1
                AddBarcode(s, cnt, bc, reader.Image.FileName, reader.Image.PageNumber)
            Next

            If cnt = 0 Then
                s = s & "NO BARCODES"
            End If

            s = s & Environment.NewLine
            Return s
        Catch ex As Exception
            Return ex.Message
        Finally
            If reader IsNot Nothing Then reader.Image.Close()
        End Try
    End Function

    Friend Function readDataMatrix(ByVal fileName As String, ByVal page As Integer) As String
        Dim reader As CiDataMatrix = Nothing

        Try
            Dim ci As CiServer = Inlite.ClearImageNet.Server.GetThreadServer()
            reader = ci.CreateDataMatrix()
            If tbrCode <> 0 Then reader.TbrCode = tbrCode
            reader.Directions = FBarcodeDirections.cibHorz Or FBarcodeDirections.cibVert Or FBarcodeDirections.cibDiag
            reader.Image.Open(fileName, page)
            reader.Find(0)
            Dim cnt As Integer = 0
            Dim s As String = ""

            For Each bc As CiBarcode In reader.Barcodes
                cnt += 1
                AddBarcode(s, cnt, bc, reader.Image.FileName, reader.Image.PageNumber)
            Next

            If cnt = 0 Then
                s = s & "NO BARCODES"
            End If

            s = s & Environment.NewLine
            Return s
        Catch ex As Exception
            Return ex.Message
        Finally
            If reader IsNot Nothing Then reader.Image.Close()
        End Try
    End Function

    Friend Function readQR(ByVal fileName As String, ByVal page As Integer) As String
        Dim reader As CiQR = Nothing

        Try
            Dim ci As CiServer = Inlite.ClearImageNet.Server.GetThreadServer()
            reader = ci.CreateQR()
            If tbrCode <> 0 Then reader.TbrCode = tbrCode
            reader.Directions = FBarcodeDirections.cibHorz Or FBarcodeDirections.cibVert Or FBarcodeDirections.cibDiag
            reader.Image.Open(fileName, page)
            reader.Find(0)
            Dim cnt As Integer = 0
            Dim s As String = ""

            For Each bc As CiBarcode In reader.Barcodes
                cnt += 1
                AddBarcode(s, cnt, bc, reader.Image.FileName, reader.Image.PageNumber)
            Next

            If cnt = 0 Then
                s = s & "NO BARCODES"
            End If

            s = s & Environment.NewLine
            Return s
        Catch ex As Exception
            Return ex.Message
        Finally
            If reader IsNot Nothing Then reader.Image.Close()
        End Try
    End Function

    Friend Function ShowInfo(ByVal image As CiImage, ByVal nPage As Integer) As String
        Dim s As String = ""
        If nPage = 1 Then s += "File = " & image.FileName & Environment.NewLine & "  PageCnt = " + image.PageCount.ToString() & Environment.NewLine

        If image.PageNumber > 0 Then
            s = s & "  Page=" & image.PageNumber.ToString() & "  Format=" & System.[Enum].GetName(GetType(Inlite.ClearImage.EFileFormat), image.Format) & "  Size=" + image.Width.ToString() & "x" + image.Height.ToString() & "  Dpi=" + image.HorzDpi.ToString() & "x" + image.VertDpi.ToString() & "  Bpp=" + image.BitsPerPixel.ToString() & Environment.NewLine
        Else
            s = s & "  Page = " & nPage.ToString() & "  Format = " & System.[Enum].GetName(GetType(Inlite.ClearImage.EFileFormat), image.Format) & Environment.NewLine
        End If

        Return s
    End Function

    Friend Function Info(ByVal fileName As String) As String
        Dim ci As CiServer = Inlite.ClearImageNet.Server.GetThreadServer()
        Dim image As CiImage = ci.CreateImage()
        Dim page As Integer = 1
        image.Open(fileName, page)
        Dim pages As Integer = image.PageCount
        txtRslt.Text = txtRslt.Text & ShowInfo(image, page)

        For page = 2 To Math.Min(pages, 20)
            image.Open(fileName, page)
            txtRslt.Text = txtRslt.Text & ShowInfo(image, page)
            System.Windows.Forms.Application.DoEvents()
        Next

        Return txtRslt.Text
    End Function

    Private Sub SavePage(ByRef s As String, ByVal image As CiImage, ByVal fileOut As String, ByVal format As EFileFormat)
        If fileOut <> "" Then

            If File.Exists(fileOut) Then
                image.Append(fileOut, format)
                s = s & "Append:" & fileOut & Environment.NewLine
            Else
                image.SaveAs(fileOut, format)
                s = s & "SaveAs:" & fileOut & Environment.NewLine
            End If
        End If
    End Sub

    Friend Function repairPage(ByVal fileName As String, ByVal page As Integer, ByVal fileOut As String, ByVal format As EFileFormat) As String
        Dim repair As CiRepair = Nothing

        Try
            Dim ci As CiServer = Inlite.ClearImageNet.Server.GetThreadServer()
            repair = ci.CreateRepair()
            repair.Image.Open(fileName, page)
            Dim s As String = "File:" & fileName & "  Page:" & page.ToString() & Environment.NewLine
            repair.AutoDeskew()
            s = s & "AutoDeskew" & Environment.NewLine
            repair.AutoCrop(50, 50, 50, 50)
            s = s & "AutoCrop (margins 50pix)" & Environment.NewLine
            SavePage(s, repair.Image, fileOut, format)
            s = s & Environment.NewLine & "--------------" & Environment.NewLine
            Return s
        Catch ex As Exception
            Return ex.Message
        Finally
            If repair IsNot Nothing Then repair.Image.Close()
        End Try
    End Function

    Friend Function repairFile(ByVal fileName As String, ByVal fileOut As String, ByVal format As EFileFormat) As String
        Dim repair As CiRepair = Nothing

        Try
            Dim ci As CiServer = Inlite.ClearImageNet.Server.GetThreadServer()
            repair = ci.CreateRepair()
            Dim s As String = ""
            Dim page As Integer = 1
            repair.Image.Open(fileName, 1)
            Dim cnt As Integer = 0
            Dim pages As Integer = repair.Image.PageCount

            While repair.Image.IsValid
                s = s & "File:" & fileName & "  Page:" & page.ToString() & Environment.NewLine
                repair.AutoDeskew()
                s = s & "AutoDeskew" & Environment.NewLine
                repair.AutoCrop(50, 50, 50, 50)
                s = s & "AutoCrop (margins 50pix)" & Environment.NewLine
                SavePage(s, repair.Image, fileOut, format)
                page += 1
                If page > pages Then Exit While
                repair.Image.Open(fileName, page)
            End While

            s = s & Environment.NewLine
            Return s
        Catch ex As Exception
            Return ex.Message
        Finally
            If repair IsNot Nothing Then repair.Image.Close()
        End Try
    End Function

    Friend Function repairStream(ByVal fileName As String, ByVal fileOut As String, ByVal format As EFileFormat) As String
        Dim repair As CiRepair = Nothing

        Try
            Dim ci As CiServer = Inlite.ClearImageNet.Server.GetThreadServer()
            repair = ci.CreateRepair()

            Using ms As MemoryStream = Utility.FileToStream(fileName)
                Dim s As String = ""
                Dim page As Integer = 1
                repair.Image.Open(ms, 1)
                Dim cnt As Integer = 0
                Dim pages As Integer = repair.Image.PageCount

                While repair.Image.IsValid
                    s = s & "File:" & fileName & "  Page:" & page.ToString() & Environment.NewLine
                    repair.AutoDeskew()
                    s = s & "AutoDeskew" & Environment.NewLine
                    repair.AutoCrop(50, 50, 50, 50)
                    s = s & "AutoCrop (margins 50pix)" & Environment.NewLine
                    Dim msOut As MemoryStream = repair.Image.SaveToStream(format)

                    If msOut IsNot Nothing Then
                        Dim pageOut As String = Path.GetDirectoryName(fileOut) & "\" & Path.GetFileNameWithoutExtension(fileOut) & ".page_" & page.ToString() & Path.GetExtension(fileOut)
                        Utility.StreamToFile(msOut, pageOut)
                    End If

                    page += 1
                    If page > pages Then Exit While
                    repair.Image.OpenPage(page)
                End While

                s = s & Environment.NewLine
                Return s
            End Using

        Catch ex As Exception
            Return ex.Message
        Finally
            If repair IsNot Nothing Then repair.Image.Close()
        End Try
    End Function

    Friend Function toolsPage(ByVal fileName As String, ByVal page As Integer) As String
        Dim tools As CiTools = Nothing

        Try
            Dim ci As CiServer = Inlite.ClearImageNet.Server.GetThreadServer()
            tools = ci.CreateTools()
            Dim s As String = ""
            Dim cnt As Integer = 0
            tools.Image.Open(fileName, page)
            Dim dSkew As Double = tools.MeasureSkew()
            s = s & String.Format("Skew {0:0.##} deg", dSkew) & Environment.NewLine

            If tools.Image.BitsPerPixel = 1 Then
                Dim obj As CiObject = tools.FirstObject()

                While obj IsNot Nothing
                    cnt += 1
                    If cnt < 10 AndAlso obj.Pixels > 1 Then AddObject(s, cnt, obj)
                    obj = tools.NextObject()
                End While

                s = s & String.Format("Object Count: {0}", cnt) & Environment.NewLine
            End If

            Return s
        Catch ex As Exception
            Return ex.Message
        Finally
            If tools IsNot Nothing Then tools.Image.Close()
        End Try
    End Function

    Friend Function serverInfo() As String
        Dim ci As CiServer = Inlite.ClearImageNet.Server.GetThreadServer()
        txtRslt.Text = txtRslt.Text & "ClearImageNet server v" + ci.VerMajor.ToString() & "." + ci.VerMinor.ToString() & "." + ci.VerRelease.ToString()
        txtRslt.Text = txtRslt.Text & Environment.NewLine
        txtRslt.Text = txtRslt.Text + ci.get_Info(EInfoType.ciModulesList, 0).Replace(vbLf, Environment.NewLine)
        Return txtRslt.Text
    End Function

    Private Sub AddBarcode(ByRef s As String, ByVal i As Long, ByVal Bc As CiBarcode, ByVal File As String, ByVal Page As Integer)
        s = s & "Barcode#:" & i.ToString()
        If File <> "" Then s += "  File:" & File
        s = s & " Page:" & Page.ToString() & Environment.NewLine
        s = s & " Type:" & System.[Enum].GetName(Bc.Type.[GetType](), Bc.Type)
        s = s & " Lng:" & Bc.Length.ToString()
        s = s & " Rect:" & Bc.Rect.left.ToString() & ":" + Bc.Rect.top.ToString() & "-" + Bc.Rect.right.ToString() & ":" + Bc.Rect.bottom.ToString()
        s = s & " Rotation:" & System.[Enum].GetName(Bc.Rotation.[GetType](), Bc.Rotation)
        s = s & Environment.NewLine & Bc.Text
        s = s & Environment.NewLine & "--------------" & Environment.NewLine
    End Sub

    Private Sub AddObject(ByRef s As String, ByVal cnt As Long, ByVal Obj As CiObject)
        s = s & "Object #" & cnt.ToString()
        s = s & " Pixels:" & Obj.Pixels.ToString() & " Intervals:" + Obj.Intervals.ToString()
        s = s & " Rect:" & Obj.Rect.left.ToString() & ":" + Obj.Rect.top.ToString() & "-" + Obj.Rect.right.ToString() & ":" + Obj.Rect.bottom.ToString()
        s = s & Environment.NewLine
    End Sub
End Class
