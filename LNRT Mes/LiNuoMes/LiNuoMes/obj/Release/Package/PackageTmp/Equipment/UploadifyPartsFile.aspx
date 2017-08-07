<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="UploadifyPartsFile.aspx.cs" Inherits="LiNuoMes.Equipment.UploadifyPartsFile" %>

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

    $(function () {
        uploadify();
    })

    function uploadify() {
        $("#uploadify").uploadify({
            method: 'post',
            uploader: '../Equipment/hs/GetEquDeviceCRUD.ashx',
            swf: '../Content/scripts/plugins/uploadify/uploadify.swf',
            buttonText: "选择文件",
            formData: { Action: 'PartsFileUploadify' },
            height: 30,
            width: 90,
            auto: false,
            multi:false,
            fileTypeExts: '*.xls;*.xlsx;*.pdf',
            fileTypeDesc: '支持格式:*.xls;*.xlsx;*.pdf',
            removeCompleted: false,
            uploadLimit: 1,
            fileSizeLimit: 1024000000,
            onSelect: function (file) {
                $("#" + file.id).prepend('<div style="float:left;width:50px;margin-right:2px;"><img src="../Content/images/filetype/' + file.type.replace('.', '') + '.png" style="width:40px;height:40px;" /></div>');
                $('.border').hide();
            },
            onUploadSuccess: function (file, data) {
                var result = JSON.parse(data);
                $("#" + file.id).find('.uploadify-progress').remove();
                $("#" + file.id).find('.data').html('，上传成功！');
                $("#" + file.id).prepend('<a class="succeed" title="成功"><i class="fa fa-check-circle"></i></a>');
                Loading(false);
                g_InputObj.val(result.sourceFileName);
                g_HiddenObj.val(result.targetFileName);
                window.setTimeout(function () {
                    dialogClose();
                }, 1000);
                return;
            },
            onUploadError: function (file) {
                $("#" + file.id).removeClass('uploadify-error');
                $("#" + file.id).find('.uploadify-progress').remove();
                $("#" + file.id).find('.data').html(' 很抱歉，上传失败！');
                $("#" + file.id).prepend('<span class="error" title="失败"><i class="fa fa-exclamation-circle"></i></span>');
            },

            //上传失败 //附件格式不正确，
            onSelectError: function (file, errorCode, errorMsg) {
                var msgText = "上传失败\n";
                switch (errorCode) {
                    
                    case SWFUpload.QUEUE_ERROR.FILE_EXCEEDS_SIZE_LIMIT:
                        msgText += "文件大小超过限制( " + $('#uploadify').uploadify('settings', 'fileSizeLimit') + " )";
                        break;
                    case SWFUpload.QUEUE_ERROR.ZERO_BYTE_FILE:
                        msgText += "文件大小为0";
                        break;
                    case SWFUpload.QUEUE_ERROR.INVALID_FILETYPE:
                        msgText += "文件格式不正确，仅限 " + $('#uploadify').uploadify('settings', 'fileTypeExts');
                        break;
                    default:
                        msgText += "错误代码：" + errorCode + "\n" + errorMsg;
                }
                dialogMsg(msgText,0);
            }
        });
    }

    function AcceptClick(inputobj, hiddenobj) {
        g_InputObj = inputobj;
        g_HiddenObj = hiddenobj;
        $('#uploadify').uploadify('upload', '*');
    }
</script>
<div style="margin: 10px">
    <div style="height: 38px;">   
        <input id="uploadify" name="uploadify" type="file" />
    </div>
    <div class="border" style="height: 35px; border-radius: 5px;">
        <div class="drag-tip" style="text-align: center; ">
            <h1 style="color: #666; font-size: 20px; font-family:'Microsoft YaHei';">请点击"选择文件"按钮, 选择要上传的文件(支持PDF、EXCEL格式)</h1>
       </div>
    </div>
</div>
    </form>
</body>
</html>


