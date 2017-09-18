<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MaterialPullResponseEdit.aspx.cs" Inherits="LiNuoMes.Mfg.MaterialPullResponseEdit" %>

<!DOCTYPE html>

<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <title></title>
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
    <script src="../Content/scripts/plugins/layout/jquery.layout.js"></script>
    <script src="../Content/scripts/plugins/dialog/dialog.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/grid.locale-cn.js"></script>
    <script src="../Content/scripts/plugins/jqgrid/jqgrid.min.js"></script>
    <script src="../Content/scripts/plugins/validator/validator.js"></script>
    <script src="../Content/scripts/utils/learun-ui.js"></script>
    <script src="../Content/scripts/utils/learun-form.js"></script>
    <link href="../css/zTreeStyle/metro.css" rel="stylesheet" />
    <script src="../js/jquery.ztree.all-3.5.min.js"></script>
    <script src="../My97DatePicker/WdatePicker.js"></script>
    <link href="../css/void_autocomplete.css" rel="stylesheet" />
    <script src="../js/void_autocomplete.js"></script>
    <style>
        html, body {
            height: 100%;
            width: 100%;
        }
    </style>
    <script>
        var id = "";
        var order = "";
        var Qty = "";
        var ItemNumber = "";
        var ItemDsca = "";
        $(function () {
            id = request('id');
            order = request('order');
            ItemNumber = request('ItemNumber');
            Qty = request('Qty');
            $("#ItemNumber").val(ItemNumber);
            $("#ActionQty").val(Qty);
            $("#ActionQty").select().focus();
            $("#ItemDsca").val(window.parent.$('#gridTable').jqGridRowValue("ItemDsca"));
            $('#ActionQty').bind('keypress', function (event) {
                if (event.keyCode == "13") {
                    AcceptClick();
                }
            });
        });

        //保存表单
        function AcceptClick() {
            if (!$('#ruleinfo').Validform()) {
                return false;
            }
            var ActionQty = $("#ActionQty").val();
            $.ajax({
                url: "MaterialPullResponse.aspx/ResponsePullInfo",
                data: "{ID:'" + id + "',ActionQty:'" + ActionQty + "'}",
                type: "post",
                dataType: "json",
                contentType: "application/json;charset=utf-8",
                success: function (data) {
                    if (data.d == "success") {
                        Loading(false);
                        dialogMsg("响应成功", 1);
                        window.parent.$('#gridTable').trigger("reloadGrid");
                        dialogClose();
                    }
                    else if (data.d == "falut") {
                        dialogMsg("响应失败", -1);
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
                    Loading(false);
                }
            });         
        }
    </script>
</head>
<body>
    <div style="margin-left: 10px; margin-top: 20px; margin-right: 30px;">
            <table class="form" id="ruleinfo" style="margin-top:10px;">
                <tr>
                    <th class="formTitle" style="width: 150px;">物料编号<font face="宋体">*</font></th>
                    <td class="formValue">
                      <input id="ItemNumber" type="text" class="form-control" readonly style="width:250px;" disabled/>
                    </td>
                </tr>
                <tr>
                    <th class="formTitle" style="width: 150px;">物料描述<font face="宋体">*</font></th>
                    <td class="formValue">
                      <input id="ItemDsca" type="text" class="form-control" readonly style="width:250px;" disabled/>
                    </td>
                </tr>
                <tr>
                    <th class="formTitle">响应数量<font face="宋体">*</font></th>
                    <td class="formValue">
                       <input id="ActionQty" type="text" class="form-control"  isvalid="yes" checkexpession="isPositiveDouble"  style="width:250px;"/>
                    </td>
                </tr>
            </table>
     </div>
</body>
</html>
