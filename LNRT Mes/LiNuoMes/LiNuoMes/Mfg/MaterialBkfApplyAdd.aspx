<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MaterialBkfApplyAdd.aspx.cs" Inherits="LiNuoMes.Mfg.MaterialBkfApplyAdd" %>


<!DOCTYPE html>

<html>
<head>
   <title>力诺瑞特平板集热器</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="renderer" content="webkit">
    
    <script src="../Content/scripts/jquery-1.11.1.min.js"></script>
    <script src="../Content/scripts/bootstrap/bootstrap.min.js"></script>
    
    <script src="../js/pdfobject.js" type="text/javascript"></script>
    <link href="../Content/scripts/plugins/jquery-ui/jquery-ui.min.css" rel="stylesheet" />
    <script src="../Content/scripts/plugins/jquery-ui/jquery-ui.min.js"></script>
    <!-- Bootstrap -->
    <link rel="stylesheet" type="text/css" href="../css/bootstrap.min.css" />
    <link href="../Content/styles/font-awesome.min.css" rel="stylesheet" />
    <link href="../Content/adminLTE/css/index.css" rel="stylesheet" />
    <link href="../Content/scripts/plugins/jqgrid/jqgrid.css" rel="stylesheet" />
    <link rel="Shortcut icon" href="../images/favicon.ico" />
    <link href="../Content/styles/learun-ui.css" rel="stylesheet" />
    <link href="../css/my.css" rel="stylesheet" media="screen">
    <script src="../Content/scripts/plugins/dialog/dialog.js"></script>
    <script src="../Content/scripts/plugins/layout/jquery.layout.js"></script>
    <script src="../Content/adminLTE/index.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
    <script src="../My97DatePicker/WdatePicker.js"></script>

    <style>
        html, body {
            height: 100%;
            width: 100%;
        }
    </style>
</head>
<body>
    <script>        $(function () {
            InitialPage();
            var currentuser = '<%=Session["UserName"] %>';
            $("#applyperson").text(currentuser);
            fndate();
            GetMember();
        });        //初始化页面        function InitialPage() {
            //layout布局
            $('#layout').layout({
                applyDemoStyles: true,
                west: {
                    size: $(window).width() * 0.35
                },
                spacing_open: 0,
                onresize: function () {
                    $(window).resize()
                }
            });
            $(".center-Panel").height($(window).height() - 40)
            $(".west-Panel").height($(window).height());

        }        //加载物料编号
        function GetMember(CatDsca,catCode) {
           
            $.ajax({
                url: "MaterialBkfApplyAdd.aspx/GetMaterialList",
                data: "{}",
                type: "post",
                dataType: "json",
                contentType: "application/json;charset=utf-8",
                success: function (data) {
                    if (data == null) return false;
                    console.log(data);
                    var _html = "";
                    $.each(data.d, function (i, row) {
                        var imgName = "Scheme.png";
                        var active = "";
                        if (row.IsActive == 1) {
                            active = "active";
                        }
                        _html += '<div class="card-box shcemeinfocheck ' + active + '" style="width: 350px;">';
                        _html += '    <div class="card-box-img" >';
                        _html += '        <img src="../Equipment/images/' + imgName + '" />';
                        _html += '    </div>';
                        _html += '    <div id="' + row.ItemNumber + '"  class="card-box-content" style="width: 280px;">';
                        _html += '        <p style="width: 250px;">编号：' + row.ItemNumber + '</p>';
                        _html += '        <p style="width: 250px;">描述：' + row.ItemDsca + '</p>';
                        //_html += '        <p>单位：' + row.UOM + '</p>';
                        _html += '    </div><i></i>';
                        _html += '</div>';
                    });
                    $(".gridPanel").html(_html);
                    $(".card-box").click(function () {
                        if (!$(this).hasClass("active")) {
                            var content = $(this);
                            content.addClass("active")
                            var material = $(this).find('div').last().attr('id');
                            //var materialqty = $(this).find('div').last().attr('data-qty');
                            dialogOpen({
                                id: "UploadifyForm",
                                title: '反冲物料数量' + material,
                                url: './MaterialApplyQty.aspx?currentmaterial=' + material,
                                width: "400px",
                                height: "200px",
                                callBack: function (iframeId) {
                                    top.frames[iframeId].AcceptClick($("#qty"));
                                    
                                    if ($("#qty").text()!="") {
                                        content.find('div').last().attr({
                                            "data-qty": $("#qty").text()
                                        });
                                        var value = $('#Description').val();
                                        value += "物料编号:" + material + "|" + "数量:" + $("#qty").text() + '\n';

                                        $('#Description').val(value);
                                        $('.poptip').remove();
                                        $('.input-error').remove();
                                    }

                                },
                                cancel: function () {
                                    content.removeClass("active");
                                }
                                
                            });

                        } else {
                            $(this).removeClass("active")
                            var value = $(this).find('div').last().attr('id');
                            var materialqty = $(this).find('div').last().attr('data-qty');
                            
                            var val = $('#Description').val();
                            val = val.replace("物料编号:" + value + "|" + "数量:" + materialqty + '\n', '');
                            $('#Description').val(val);
                        }
                    });
                    Loading(false);
                }, beforeSend: function () {
                    
                    $('#Description').text("");
                    Loading(true);
                }
            });
            //模糊查询模板（注：这个方法是理由jquery查询）
            $("#txt_TreeKeyword").keyup(function () {
                var value = $(this).val();
                if (value != "") {
                    window.setTimeout(function () {
                        $(".shcemeinfocheck")
                         .hide()
                         .filter(":contains('" + (value.toLocaleUpperCase()) + "')")
                         .show();
                    }, 200);
                } else {
                    $(".shcemeinfocheck").show();
                }
            }).keyup();
        }        //保存表单
        function AcceptClick() {
            var userIds = [];

            $('.gridPanel .active .card-box-content').each(function () {

                userIds.push($(this).attr('id') + '|' + $(this).attr('data-qty'));
               
            });
            
            var ApplyUser = $("#applyperson").text();
            $.ajax({
                url: "MaterialBkfApplyAdd.aspx/SaveApply",  
                data: JSON.stringify({ ApplyUser: ApplyUser, arr: userIds }),
                type: "post",
                async: true,
                dataType: "json",
                contentType: "application/json;charset=utf-8",
                success: function (data) {
                    if (data.d == "success") {
                        Loading(false);
                        dialogMsg("保存成功", 1);
                        window.parent.$('#gridTable').trigger("reloadGrid");
                        //$.currentIframe().$("#gridTable").trigger("reloadGrid");
                        dialogClose();
                    }
                    else if (data.d == "falut") {
                        dialogMsg("保存失败", -1);
                    }
                   
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                    Loading(false);
                    dialogMsg(errorThrown, -1);
                },
                beforeSend: function () {
                    Loading(true, "正在保存数据");
                },
                complete: function () {
                    //$("#gridTable").trigger("reloadGrid");
                    Loading(false);
                }
            });
        }        function request(name) {
            var reg = new RegExp("(^|&)" + name + "=([^&]*)(&|$)");
            var r = window.location.search.substr(1).match(reg);
            if (r != null) return unescape(r[2]); return null;
        }        function fndate() {
            var xhr = null;
            if (window.XMLHttpRequest) {
                xhr = new window.XMLHttpRequest();
            } else { // ie
                xhr = new ActiveObject("Microsoft")
            }
            // 通过get的方式请求当前文件
            xhr.open("get", "/");
            xhr.send(null);
            // 监听请求状态变化
            xhr.onreadystatechange = function () {
                var time = null,
                    curDate = null;
                if (xhr.readyState === 2) {
                    var seperator1 = "-";
                    // 获取请求头里的时间戳
                    time = xhr.getResponseHeader("Date");
                    //console.log(xhr.getAllResponseHeaders())
                    curDate = new Date(time);
                    //当前时间
                    var month = curDate.getMonth() + 1;
                    var strDate = curDate.getDate();
                    if (month >= 1 && month <= 9) {
                        month = "0" + month;
                    }
                    if (strDate >= 0 && strDate <= 9) {
                        strDate = "0" + strDate;
                    }
                    currentdate = curDate.getFullYear() + seperator1 + month + seperator1 + strDate;
                    $("#applytime").text(currentdate);
                   
                }
            }
        }    </script>
   <div class="ui-layout" id="layout" style="height: 100%; width: 100%;">
    <div class="ui-layout-west">
        <div class="west-Panel" style="margin: 0px; border-top: none; border-left: none; border-bottom: none;">
            <div style="color:#9f9f9f;padding-top:5px; padding-bottom:5px;padding-left:8px;"><i style="padding-right:5px;" class="fa fa-info-circle"></i><span>填写内容,选择右侧物料编号</span></div>
            <table class="form" id="ruleinfo">
                <tr>
                    <th class="formTitle">申请人<font face="宋体">*</font></th>
                    <td class="formValue">
                        <label id="applyperson"></label>
                        <label id="qty" hidden="hidden"></label>
                    </td>
                </tr>
                <tr>
                    <th class="formTitle">申请时间<font face="宋体">*</font></th>
                    <td class="formValue">
                        <label id="applytime"></label>
                    </td>
                </tr>
                
                <tr>
                    <th class="formTitle" valign="top" style="padding-top: 4px;">
                        物料信息<font face="宋体">*</font>
                    </th>
                    <td class="formValue" colspan="3">
                        <textarea id="Description" readonly class="form-control" style="height: 410px; width: 350px;" isvalid="yes" checkexpession="NotNull"></textarea>
                    </td>
                </tr>
                
            </table>
        </div>
    </div>
    <div class="ui-layout-center">
        <div class="treesearch">
            <input id="txt_TreeKeyword" type="text" class="form-control" style="border-top: none;" placeholder="请输入要查询关键字" />
            <span id="btn_TreeSearch" class="input-query" title="Search"><i class="fa fa-search"></i></span>
        </div>
        <div class="center-Panel" style="margin: 0px; border-right: none; border-left: none; border-bottom: none; background-color: #fff; overflow: auto; padding-bottom: 10px;">
            <div class="gridPanel">
            </div>
        </div>
    </div>
   </div>   <style>
    .form .formTitle {
        width:65px;
        font-size:9pt;
    }
    .card-box-img {
    line-height:initial;
    }
    .card-box-img img {
    width: 58px;
    height: 58px;
    border-radius: 0px;
    margin-left:0px;
    }
    .card-box-content p{
        height: 30px;
    }
    </style>
</body>
</html>

