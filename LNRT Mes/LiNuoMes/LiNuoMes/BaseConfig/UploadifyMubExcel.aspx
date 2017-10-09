<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UploadifyMubExcel.aspx.cs" Inherits="FramWork.BaseConfig.UploadifyMubExcel" %>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="content-type" content="text/html; charset=UTF-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>力诺瑞特平板集热器</title>
    <!--框架必需start-->
    <script src="../Content/scripts/jquery-1.11.1.min.js"></script>
    <link href="../Content/styles/font-awesome.min.css" rel="stylesheet" />
    <link href="../Content/scripts/plugins/jquery-ui/jquery-ui.min.css" rel="stylesheet" />
    <script src="../Content/scripts/plugins/jquery-ui/jquery-ui.min.js"></script>
    <!--框架必需end-->
    <!--bootstrap组件start-->
    <link href="../Content/scripts/bootstrap/bootstrap.min.css" rel="stylesheet" />
    <script src="../Content/scripts/bootstrap/bootstrap.min.js"></script>
    <!--bootstrap组件end-->
  
    <link href="../Content/styles/learun-ui.css" rel="stylesheet"/>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
   
</head>
<body>
    
    <form id="form1">
        
<link href="../Content/scripts/plugins/uploadify/uploadify.css" rel="stylesheet" />
<link href="../Content/scripts/plugins/uploadify/uploadify.extension.css" rel="stylesheet" />
<script src="../Content/scripts/plugins/uploadify/jquery.uploadify.min.js"></script>
<script>
    var g_InputObj;
    var g_HiddenObj;
    var g_Grid;

    $(function () {
        uploadify();
    })

    function uploadify() {

        $("#uploadify").uploadify({
            method: 'post',
            uploader: 'GetSetBaseConfig.ashx',
            swf: '../Content/scripts/plugins/uploadify/uploadify.swf',
            buttonText: "选择文件",
            formData: {
                "Action": 'MES_MUB_CONFIG_FILE_UPLOAD',
                "GoodsCode" : "0000000000"
            },
            height: 30,
            width: 90,
            auto: false,
            multi:false,
            fileTypeDesc: '支持格式:*.xls;*.xlsx',
            fileTypeExts: '*.xls;*.xlsx',
            removeCompleted: false,
            uploadLimit: 1,
            fileSizeLimit: 1024000000,
            onSelect: function (file) {
                $("#" + file.id).prepend('<div style="float:left;width:50px;margin-right:2px;"><img src="../Content/images/filetype/' + file.type.replace('.', '') + '.png" style="width:40px;height:40px;" /></div>');
                $('.border').hide();
            },
            onUploadSuccess: function (file, data) {
                var result = JSON.parse(data);
                if (result.result == "success") {
                    $("#" + file.id).find('.uploadify-progress').remove();
                    $("#" + file.id).find('.data').html('，上传成功！');
                    $("#" + file.id).prepend('<a class="succeed" title="成功"><i class="fa fa-check-circle"></i></a>');
                    Loading(false);
                    g_InputObj.text(result.sourceFileName);
                    g_HiddenObj.text(result.targetFileName);
                    g_Grid.jqGrid('setGridParam',{
                        postData: {
                            "TargetFileName": result.targetFileName,
                            "OPtype" : "UPLOADREVIEW"
                        }
                    }).trigger('reloadGrid');
                    window.setTimeout(function () {
                        dialogClose();
                    }, 1000);
                }
                else {
                    $("#" + file.id).find('.uploadify-progress').remove();
                    $("#" + file.id).find('.data').html(',' + result.msg + '！');
                    $("#" + file.id).prepend('<a class="succeed" title="失败"><i class="fa fa-times"></i></a>');
                }
                return;
            },
            onUploadError: function (file) {
                $("#" + file.id).removeClass('uploadify-error');
                $("#" + file.id).find('.uploadify-progress').remove();
                $("#" + file.id).find('.data').html(' 很抱歉，上传失败！');
                $("#" + file.id).prepend('<span class="error" title="失败"><i class="fa fa-exclamation-circle"></i></span>');
            }
        });
    }

    function AcceptClick(inputobj, hiddenobj, gridobj) {
        g_InputObj = inputobj;
        g_HiddenObj = hiddenobj;
        g_Grid = gridobj;
        $('#uploadify').uploadify('upload', '*');
    }

</script>
<div style="margin: 10px">
    <div style="height: 38px;">   
        <input id="uploadify" name="uploadify" type="file" />
    </div>
    <div class="border" style="height: 35px; border-radius: 5px;">
        <div class="drag-tip" style="text-align: center; ">
            <h1 style="color: #666; font-size: 20px; font-family:'Microsoft YaHei';">请点击"选择文件"按钮, 选择要上传的文件</h1>
       </div>
    </div>
</div>
    </form>
</body>
</html>
