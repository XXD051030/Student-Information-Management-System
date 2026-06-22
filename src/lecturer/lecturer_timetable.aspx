<%@ Page Language="C#" MasterPageFile="~/lecturer/LecturerLayout.master" AutoEventWireup="true" CodeBehind="lecturer_timetable.aspx.cs" Inherits="src.lecturer.lecturer_timetable" Title="Timetable - INTI Lecturer Portal" %>
<asp:Content ContentPlaceHolderID="MainContent" runat="server">
    <div>
        <p class="text-slate-500" style="font-size:13px;font-weight:500">Lecturer</p>
        <h1 class="mt-1 text-slate-900" style="font-size:28px;font-weight:700;letter-spacing:-0.01em">Timetable Management</h1>
        <p class="mt-1 text-slate-500" style="font-size:14px">Create and maintain class times and rooms for your course offerings.</p>
    </div>

    <asp:Panel ID="messagePanel" runat="server" Visible="false" CssClass="mt-5 rounded-lg border px-4 py-3 text-sm">
        <asp:Literal ID="messageLiteral" runat="server"></asp:Literal>
    </asp:Panel>

    <section class="mt-6 grid gap-6 xl:grid-cols-[360px_minmax(0,1fr)]">
        <div class="rounded-lg border border-slate-200 bg-white">
            <div class="border-b border-slate-100 px-6 py-4">
                <h2 class="text-slate-900" style="font-size:15px;font-weight:700"><asp:Literal ID="formTitleLiteral" runat="server" Text="Add timetable slot"></asp:Literal></h2>
                <p class="mt-0.5 text-slate-500" style="font-size:12.5px">Times are saved directly to the TIMETABLES table.</p>
            </div>
            <div class="space-y-4 px-6 py-5">
                <asp:HiddenField ID="timetableIdField" runat="server" Value="0" />
                <label class="block">
                    <span class="block text-slate-500 uppercase" style="font-size:11px;font-weight:600;letter-spacing:0.06em">Course offering</span>
                    <asp:DropDownList ID="offeringList" runat="server" CssClass="mt-1.5 h-10 w-full rounded-md border border-slate-200 bg-white px-3 text-slate-700 outline-none focus:border-[#e0162b]/40 focus:ring-4 focus:ring-[#e0162b]/10" style="font-size:13px"></asp:DropDownList>
                </label>
                <label class="block">
                    <span class="block text-slate-500 uppercase" style="font-size:11px;font-weight:600;letter-spacing:0.06em">Day</span>
                    <asp:DropDownList ID="dayList" runat="server" CssClass="mt-1.5 h-10 w-full rounded-md border border-slate-200 bg-white px-3 text-slate-700 outline-none focus:border-[#e0162b]/40 focus:ring-4 focus:ring-[#e0162b]/10" style="font-size:13px"></asp:DropDownList>
                </label>
                <div class="grid grid-cols-2 gap-3">
                    <label class="block">
                        <span class="block text-slate-500 uppercase" style="font-size:11px;font-weight:600;letter-spacing:0.06em">Start</span>
                        <asp:TextBox ID="startTimeText" runat="server" TextMode="Time" CssClass="mt-1.5 h-10 w-full rounded-md border border-slate-200 bg-white px-3 outline-none focus:border-[#e0162b]/40 focus:ring-4 focus:ring-[#e0162b]/10" style="font-size:13px"></asp:TextBox>
                    </label>
                    <label class="block">
                        <span class="block text-slate-500 uppercase" style="font-size:11px;font-weight:600;letter-spacing:0.06em">End</span>
                        <asp:TextBox ID="endTimeText" runat="server" TextMode="Time" CssClass="mt-1.5 h-10 w-full rounded-md border border-slate-200 bg-white px-3 outline-none focus:border-[#e0162b]/40 focus:ring-4 focus:ring-[#e0162b]/10" style="font-size:13px"></asp:TextBox>
                    </label>
                </div>
                <label class="block">
                    <span class="block text-slate-500 uppercase" style="font-size:11px;font-weight:600;letter-spacing:0.06em">Room</span>
                    <asp:TextBox ID="roomText" runat="server" MaxLength="50" placeholder="e.g. Room A-101" CssClass="mt-1.5 h-10 w-full rounded-md border border-slate-200 bg-white px-3 outline-none focus:border-[#e0162b]/40 focus:ring-4 focus:ring-[#e0162b]/10" style="font-size:13px"></asp:TextBox>
                </label>
                <div class="flex gap-2 pt-1">
                    <asp:Button ID="saveButton" runat="server" Text="Save slot" OnClick="Save_Click" CssClass="h-10 flex-1 cursor-pointer rounded-md bg-[#e0162b] px-4 text-white hover:bg-[#a01020]" style="font-size:13px;font-weight:600" />
                    <asp:Button ID="cancelButton" runat="server" Text="Cancel" OnClick="Cancel_Click" CausesValidation="false" Visible="false" CssClass="h-10 cursor-pointer rounded-md border border-slate-200 bg-white px-4 text-slate-600 hover:bg-slate-50" style="font-size:13px;font-weight:600" />
                </div>
            </div>
        </div>

        <div class="min-w-0 rounded-lg border border-slate-200 bg-white">
            <div class="border-b border-slate-100 px-6 py-4">
                <h2 class="text-slate-900" style="font-size:15px;font-weight:700">Your timetable slots</h2>
                <p class="mt-0.5 text-slate-500" style="font-size:12.5px"><%= SlotCount %> scheduled slot(s)</p>
            </div>
            <div class="overflow-x-auto">
                <table class="min-w-full">
                    <thead class="border-b border-slate-100 bg-slate-50/60 text-slate-500">
                        <tr>
                            <th class="px-6 py-3 text-left uppercase" style="font-size:11px;font-weight:600">Course</th>
                            <th class="px-6 py-3 text-left uppercase" style="font-size:11px;font-weight:600">Day</th>
                            <th class="px-6 py-3 text-left uppercase" style="font-size:11px;font-weight:600">Time</th>
                            <th class="px-6 py-3 text-left uppercase" style="font-size:11px;font-weight:600">Room</th>
                            <th class="px-6 py-3 text-right uppercase" style="font-size:11px;font-weight:600">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="slotsRepeater" runat="server" OnItemCommand="Slots_ItemCommand">
                            <ItemTemplate>
                                <tr class="border-b border-slate-100 hover:bg-slate-50/60">
                                    <td class="px-6 py-3"><div class="font-medium text-slate-900" style="font-size:12.5px"><%# Eval("CourseCode") %></div><div class="text-slate-500" style="font-size:11.5px"><%# Eval("CourseName") %></div></td>
                                    <td class="px-6 py-3 text-slate-700" style="font-size:12.5px"><%# Eval("DayOfWeek") %></td>
                                    <td class="px-6 py-3 text-slate-700" style="font-size:12.5px"><%# FormatTime(Eval("StartTime")) %> – <%# FormatTime(Eval("EndTime")) %></td>
                                    <td class="px-6 py-3 text-slate-700" style="font-size:12.5px"><%# Eval("Venue") %></td>
                                    <td class="px-6 py-3 text-right">
                                        <asp:LinkButton runat="server" CommandName="EditSlot" CommandArgument='<%# Eval("TimetableId") %>' CssClass="mr-1 inline-flex h-8 items-center rounded-md border border-slate-200 px-3 text-slate-600 hover:bg-slate-50" style="font-size:12px;font-weight:600">Edit</asp:LinkButton>
                                        <asp:LinkButton runat="server" CommandName="DeleteSlot" CommandArgument='<%# Eval("TimetableId") %>' OnClientClick="return confirm('Delete this timetable slot?');" CssClass="inline-flex h-8 items-center rounded-md border border-[#e0162b]/20 px-3 text-[#e0162b] hover:bg-[#e0162b]/5" style="font-size:12px;font-weight:600">Delete</asp:LinkButton>
                                    </td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                        <asp:PlaceHolder ID="emptySlotsPanel" runat="server" Visible="false">
                            <tr><td colspan="5" class="px-6 py-12 text-center text-slate-400" style="font-size:13px">No timetable slots yet.</td></tr>
                        </asp:PlaceHolder>
                    </tbody>
                </table>
            </div>
        </div>
    </section>
</asp:Content>
<asp:Content ContentPlaceHolderID="ScriptsPlaceholder" runat="server">
    <script src="<%= ResolveUrl("~/js/admin/shared/icons.js") %>"></script>
</asp:Content>
