//
//  JSParserTests.swift
//
//
//  Created by Evan Anderson on 8/15/24.
//

#if compiler(>=6.0)

import Testing
@testable import Parser

struct JSParserTests {
    @Test func parseJS() {
        JSParser.parse("""
        #!hoopla
        if(true) {
            let bro=5;
            const lil=undefined;
            // what
            /*
            ding dong
            */
            var yoink=true;
        }
        """
        )
    }
}

extension JSParserTests {
    @Test func parseJS2() {
        JSParser.parse("""
        function toggle_filter_options() {
            getElement("filters_dropdown").classList.toggle("first_responder");
        }

        function update_filter_dropdown_tables() {
            var days_html = "<table><caption>Day</caption><tbody>",
                    teams_html = "",
                    time_slots_html = "<table><caption>Time</caption><tbody>",
                    matchup_slots_html = "<table><caption>Location</caption>";
            for (day_string of summary_values.day_indexes) {
                days_html += "<tr><td><label for='filter_day_" + day_string + "'>" + day_string + "</td><td><input type='checkbox' id='filter_day_" + day_string + "' onchange='filter_matchups()'></td></tr>";
            }
            getElement("filters_dropdown_day_indexes").innerHTML = days_html + "</tbody></table>";

            for (division of summary_values.unique_divisions_sorted) {
                teams_html += "<table>";
                if (division == undefined || division == null || division.length == 0 || summary_values.unique_divisions_sorted.length == 1) {
                    teams_html += "<caption>Team</caption>";
                } else {
                    teams_html += `<caption onclick='toggle_filtered_division("` + division + `")' style='cursor:pointer'>` + division + " Division</caption>";
                }

                const team_ids_in_division = summary_values.unique_teams_in_division[division];
                for (team_id of team_ids_in_division) {
                    teams_html += "<tr><td><label for='filter_team_" + team_id + "'>" + summary_values.team_names_dictionary[team_id] + "</label></td><td><input type='checkbox' id='filter_team_" + team_id + "' onchange='filter_matchups()'></td></tr>";
                }
                teams_html += "</table>";
            }
            getElement("filters_dropdown_teams").innerHTML = teams_html;

            for (time of summary_values.unique_times_sorted) {
                var time_id = time;
                while (time_id.endsWith(" ") || time_id.endsWith("\n")) {
                    time_id = time_id.slice(0, -1);
                }
                time_id = time_id.replaceAll(" ", "%s%");
                time_slots_html += "<tr><td><label for='filter_time_" + time_id + "'>" + time + "</label></td><td><input type='checkbox' id='filter_time_" + time_id + "' onchange='filter_matchups()'></td></tr>";
            }
            getElement("filters_dropdown_time_slots").innerHTML = time_slots_html + "</tbody></table>";

            for (slot of summary_values.unique_slots_sorted) {
                const slot_id = slot.replaceAll(" ", "%s%");
                matchup_slots_html += "<tr><td><label for='filter_location_" + slot_id + "'>" + slot + "</label></td><td><input type='checkbox' id='filter_location_" + slot_id + "' onchange='filter_matchups()'></td></tr>";
            }
            getElement("filters_dropdown_matchup_slots").innerHTML = matchup_slots_html + "</table>";
        }

        function get_filtered_set(element_id, id_prefix) {
            const elements = getChildrenThatStartWithID(getElement(element_id), id_prefix);
            var ids = new Set();
            for (e of elements) {
                if (e.checked) {
                    ids.add(e.id.split("_").pop().replaceAll("%s%", " "));
                }
            }
            return ids;
        }
        function get_filtered_day_indexes() {
            return get_filtered_set("filters_dropdown_day_indexes", "filter_day_");
        }
        function get_filtered_team_ids() {
            return get_filtered_set("filters_dropdown_teams", "filter_team_");
        }
        function get_filtered_time_slots() {
            return get_filtered_set("filters_dropdown_time_slots", "filter_time_");
        }
        function get_filtered_matchup_slots() {
            return get_filtered_set("filters_dropdown_matchup_slots", "filter_location_");
        }

        function toggle_filtered_division(division_id) {
            const team_ids_in_division = summary_values.unique_teams_in_division[division_id];
            for (team_id of team_ids_in_division) {
                const element = getElement("filter_team_" + team_id);
                element.checked = !element.checked;
            }
            filter_matchups();
        }

        function filter_matchups() {
            const all_matchups_element = getElement("matchups"), matchup_trs = document.getElementsByClassName("league_matchup"),
                    filtered_days = get_filtered_day_indexes(), filtered_team_ids = get_filtered_team_ids(), filtered_time_slots = get_filtered_time_slots(), filtered_matchup_slots = get_filtered_matchup_slots();
            for (element of matchup_trs) {
                element.removeAttribute("style");
            }
            for (element of all_matchups_element.children) {
                element.style.removeProperty("display");
            }

            if (filtered_days.size == 0 && filtered_team_ids.size == 0 && filtered_time_slots.size == 0 && filtered_matchup_slots.size == 0) {
                return;
            }
            for (e of all_matchups_element.children) {
                const day = e.id.split("_")[1];
                var shown = new Set(), hidden = new Set();
                if (filtered_days.size == 0 || filtered_days.has(day)) {
                    const time_slot = e.getElementsByClassName("starts")[0].innerHTML, matchups = e.getElementsByClassName("league_matchup");
                    for (matchup of matchups) {
                        const allowed_team = filtered_team_ids.size == 0 || filtered_team_ids.has(matchup.getElementsByClassName("home_id")[0].innerHTML) || filtered_team_ids.has(matchup.getElementsByClassName("away_id")[0].innerHTML),
                                allowed_time_slot = filtered_time_slots.size == 0 || filtered_time_slots.has(time_slot),
                                allowed_matchup_slot = filtered_matchup_slots.size == 0 || filtered_matchup_slots.has(matchup.getElementsByClassName("league_matchup_slot")[0].innerHTML);
                        if (allowed_team && allowed_time_slot && allowed_matchup_slot) {
                            shown.add(matchup);
                        } else {
                            hidden.add(matchup);
                        }
                    }
                }
                if (shown.size == 0) {
                    e.style.display = "none";
                } else {
                    for (matchup of hidden) {
                        matchup.style.display = "none";
                    }
                }
            }
        }
        """)
    }
}

#endif