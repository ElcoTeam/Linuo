<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="FileSearchInfo.aspx.cs" Inherits="LiNuoMes.Equipment.FileSearchInfo" %>

<!DOCTYPE html>

<html>
<head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <title>UploadifyForm</title>
    <!--框架必需start-->
    <script src="../Content/scripts/jquery-1.11.1.min.js"></script>
    <link href="../Content/styles/font-awesome.min.css" rel="stylesheet" />
    <link href="../Content/scripts/plugins/jquery-ui/jquery-ui.min.css" rel="stylesheet" />
    <script src="../Content/scripts/plugins/jquery-ui/jquery-ui.min.js"></script>
    <!--框架必需end-->
    <!--bootstrap组件start-->
    <link href="../Content/scripts/bootstrap/bootstrap.min.css" rel="stylesheet" />
<%--    <link href="/Content/scripts/bootstrap/bootstrap.extension.css" rel="stylesheet" />--%>
    <script src="../Content/scripts/bootstrap/bootstrap.min.js"></script>
    <!--bootstrap组件end-->
  
    <link href="../Content/styles/learun-ui.css" rel="stylesheet"/>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../js/pdfobject.js"></script>
</head>
<body>
    <form id="form1" runat="server">
    <div style="height:700px;margin: 10px">
    <div style="height:700px;">
        <div class="border" style="height: 100%; border-radius: 5px;" id="example1" >                                                   
        </div>
    </div>
    </div>
    </form>
    <script>
        var folderId = request('folderId');
       
        console.log(folderId);
       
        var options = {
            pdfOpenParams: {
                pagemode: "none"
                , navpanes: 0
                , toolbar: 0
                , statusbar: 0
                //   ,view:"FitBH"
            }
                , width: "100%"
                , height: "100%"
                , page: "1"
                , fallbackLink: "<p>Please install the PDF Reader First!</p>"
        };

        var myPDF = PDFObject.embed("./PmSpecFile/" + folderId+".pdf", "#example1", options);

    </script>
</body>
</html>

