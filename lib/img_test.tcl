

##############################################################################
# $Id: file.tcl,v 1.1 8/6/25 18:46:08 rozen Exp rozen $
#
# img_test - procedures to check for the present of image files in the cwd.
#
# Copyright (C) 2025 Donald Rozenberg
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software

# This proc findNonExistentImageFiles is called when opening a project
# to insure that any image files required by the projec are in the
# Current Working Directory. It is called from vTcl:open in
# file.tcl. I find it interesting that I used Google Gemini to
# generate the code which ran with the removal of a douple of subtle
# bugs related to braces within strings.

proc findNonExistentImageFiles {file_path} {
    set found_image_list 0
    set found_closing_brace 0
    set image_list_content {}
    set quoted_strings_found {}
    set non_existent_files {}
    if {[catch {set file_id [open $file_path r]} err]} {
        puts "Error: Could not open file \"$file_path\": $err"
        return {}
    }

    while {[gets $file_id line] >= 0} {
		if {!$found_image_list} {
            if {[string match "*set image_list \{*" $line]} {
                set found_image_list 1
                lappend image_list_content $line
            }
        } else {
            lappend image_list_content $line
            if {[string match "\}" $line]} {
                set found_closing_brace 1
                break
            }
        }
    }

    close $file_id

    if {$found_image_list && $found_closing_brace} {
        foreach collected_line $image_list_content {
			if {[regexp  {\"([^\"]*)\"} $collected_line xxx file_name]} {
				lappend quoted_strings_found $file_name
			}
        }


        if {[llength $quoted_strings_found] > 0} {
            set current_dir [pwd]

            foreach relative_path $quoted_strings_found {
                set found_file 0
                if {$relative_path eq ""} {
                    continue
                }

                set q_inner [list $current_dir]
                set visited_inner [list $current_dir]

                while {[llength $q_inner] > 0} {
                    set current_scan_dir [lindex $q_inner 0]
                    set q_inner [lrange $q_inner 1 end]

                    set full_path [file join $current_scan_dir $relative_path]

                    if {[file exists $full_path]} {
                        set found_file 1
                        break
                    }

                    foreach item [glob -nocomplain -type d \
                            [file join $current_scan_dir *]] {
                        if {[lsearch -exact $visited_inner $item] == -1} {
                            lappend q_inner $item
                            lappend visited_inner $item
                        }
                    }
                }

                if {!$found_file} {
                    lappend non_existent_files $relative_path
                }
            }
        }
    } elseif {$found_image_list && !$found_closing_brace} {

    }

    # --- REMOVE DUPLICATES ---
    return [lsort -unique $non_existent_files]
}

# --- GUI Display Procedure ---

proc displayNonExistentFilesGUI {missing_files_list} {
    # Initialize Tk
    package require Tk

    # Create the main window
    wm withdraw .
    toplevel .main_window
    wm title .main_window "Non-Existent Image File Checker"
    # Protocol for window manager's close button (X button)
    wm protocol .main_window WM_DELETE_WINDOW {destroy .main_window; update}
 
    # Frame for results
    set results_frame [ttk::labelframe .main_window.results_frame -text \
            "Non-Existent Files Found"]
    # Adjust packing as it's now the first content frame
    pack $results_frame -padx 10 -pady 10 -fill both -expand yes

    # Instructional Label
    ttk::label $results_frame.instruction_label \
        -text "Files listed below were not found in the current directory or \
                its subdirectories." \
        -wraplength 400
    grid $results_frame.instruction_label -row 0 -column 0 -columnspan 2 \
            -padx 5 -pady {0 5} -sticky w

    # Listbox to display results
    set listbox_width 60
    set listbox_height 15
    listbox $results_frame.listbox -width $listbox_width \
            -height $listbox_height -yscrollcommand \
            "$results_frame.scrollbar set"
	$results_frame.listbox config -font $::vTcl(pr,gui_font_text) ;# Rozen
    grid $results_frame.listbox -row 1 -column 0 -padx 5 -pady 5 -sticky nwes

    # Scrollbar for listbox
    ttk::scrollbar $results_frame.scrollbar -orient vertical \
            -command "$results_frame.listbox yview"
    grid $results_frame.scrollbar -row 1 -column 1 -sticky ns

    grid rowconfigure $results_frame 1 -weight 1
    grid columnconfigure $results_frame 0 -weight 1

    # Initial population of the listbox
    if {[llength $missing_files_list] > 0} {
        foreach item $missing_files_list {
            $results_frame.listbox insert end $item
        }
    } else {
        $results_frame.listbox insert end "No non-existent files found \
                (initial check)."
    }

    # Close Button
    ttk::button .main_window.close_btn -text "Close" -command {
        destroy .main_window
        update
    }
    pack .main_window.close_btn -padx 10 -pady 10 -side bottom -anchor e

    # Center the window
    update idletasks
    set x [expr {([winfo screenwidth .] - [winfo width .main_window]) / 2}]
    set y [expr {([winfo screenheight .] - [winfo height .main_window]) / 2}]
    wm geometry .main_window +$x+$y
    wm deiconify .main_window

    # tkwait window waits for the window to be destroyed
    tkwait window .main_window
}





