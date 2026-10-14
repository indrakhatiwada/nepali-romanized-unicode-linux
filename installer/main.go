package main

import (
	"embed"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/charmbracelet/bubbles/list"
	"github.com/charmbracelet/bubbles/spinner"
	"github.com/charmbracelet/bubbles/viewport"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

//go:embed data/*
var embeddedScripts embed.FS

type item struct {
	title string
	desc  string
}

func (i item) Title() string       { return i.title }
func (i item) Description() string { return i.desc }
func (i item) FilterValue() string { return i.title + i.desc }

type runResult struct {
	name string
	out  string
	err  error
}

type runDoneMsg runResult

const (
	stateMenu    = iota
	stateRunning = iota
	stateDone    = iota
)

type model struct {
	state           int
	width           int
	height          int
	menu            list.Model
	spin            spinner.Model
	log             viewport.Model
	active          string
	fontsInstalled  bool
	userInstalled   bool
	systemInstalled bool
	toggleInstalled bool
}

func detectUserLayoutInstalled() bool {
	base := filepath.Join(os.Getenv("HOME"), ".config", "xkb")
	if _, err := os.Stat(filepath.Join(base, "symbols", "nepali_unicode_romanized")); err != nil {
		return false
	}
	b, err := os.ReadFile(filepath.Join(base, "rules", "evdev.xml"))
	if err != nil {
		return false
	}
	return strings.Contains(string(b), "nepali_unicode_romanized")
}

func detectSystemLayoutInstalled() bool {
	base := "/usr/share/X11/xkb"
	if _, err := os.Stat(filepath.Join(base, "symbols", "nepali_unicode_romanized")); err != nil {
		return false
	}
	b, err := os.ReadFile(filepath.Join(base, "rules", "evdev.xml"))
	if err != nil {
		return false
	}
	return strings.Contains(string(b), "nepali_unicode_romanized")
}

func detectFontsInstalled() bool {
	out, err := exec.Command("fc-list", ":", "family").CombinedOutput()
	if err != nil {
		return false
	}
	return strings.Contains(string(out), "Devanagari")
}

func detectToggleInstalled() bool {
	data, err := os.ReadFile(filepath.Join(os.Getenv("HOME"), ".config", "hypr", "input.lua"))
	if err != nil {
		return false
	}
	s := string(data)
	return strings.Contains(s, "nepali_unicode_romanized") && strings.Contains(s, "grp:alt_shift_toggle")
}

func menuItems(fontsInstalled, userInstalled, systemInstalled, toggleInstalled bool) []list.Item {
	fontDesc := "Optional download if missing"
	if fontsInstalled {
		fontDesc = "Installed"
	}
	userDesc := "Not installed"
	if userInstalled {
		userDesc = "Installed"
	}
	systemDesc := "Not installed"
	if systemInstalled {
		systemDesc = "Installed"
	}
	toggleDesc := "Not applied"
	if toggleInstalled {
		toggleDesc = "Applied"
	}
	return []list.Item{
		item{"Install (user-level)", "No sudo. ~/.config/xkb (" + userDesc + ")"},
		item{"Install (system-wide)", "Requires sudo. /usr/share/X11/xkb (" + systemDesc + ")"},
		item{"Install Devanagari fonts", fontDesc},
		item{"Validate layout", "xkbcli compile-keymap test"},
		item{"Enable Alt+Shift toggle (apply)", toggleDesc},
		item{"Show verified install command", "Print secure one-liner"},
		item{"Exit", "Quit"},
	}
}

func initialModel() model {
	f := detectFontsInstalled()
	u := detectUserLayoutInstalled()
	si := detectSystemLayoutInstalled()
	tm := detectToggleInstalled()
	items := menuItems(f, u, si, tm)
	m := list.New(items, list.NewDefaultDelegate(), 80, 24)
	m.Title = "Nepali Unicode Romanized"
	m.SetShowStatusBar(true)
	m.SetFilteringEnabled(false)
	s := spinner.New()
	s.Spinner = spinner.Dot
	lg := lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("6"))
	m.Title = lg.Render("Nepali Unicode Romanized Installer")
	vp := viewport.New(80, 24)
	vp.SetContent("No output yet.")
	return model{state: stateMenu, menu: m, spin: s, log: vp, fontsInstalled: f, userInstalled: u, systemInstalled: si, toggleInstalled: tm}
}

func sidecar(name string) string {
	exe, _ := os.Executable()
	exe, _ = filepath.EvalSymlinks(exe)
	dir := filepath.Dir(exe)
	candidates := []string{
		filepath.Join(dir, name),
		filepath.Join(dir, "..", name),
		name,
	}
	for _, c := range candidates {
		if st, err := os.Stat(c); err == nil && !st.IsDir() {
			return c
		}
	}
	return deployEmbedded(name)
}

func runCommand(name, cmd string, args ...string) runResult {
	c := exec.Command(cmd, args...)
	b, err := c.CombinedOutput()
	out := string(b)
	if out == "" {
		out = "(no output)"
	}
	return runResult{name: name, out: out, err: err}
}

func runFonts() runResult {
	candidates := []struct {
		pm   string
		file string
		str  string
	}{
		{"pacman", "pacman", "sudo pacman -S --needed --noconfirm noto-fonts"},
		{"apt-get", "apt-get", "sudo apt-get install -y fonts-noto"},
		{"dnf", "dnf", "sudo dnf install -y google-noto-sans-devanagari-fonts"},
	}
	tried := []string{}
	for _, c := range candidates {
		if _, err := exec.LookPath(c.pm); err != nil {
			continue
		}
		sudo, err := exec.LookPath("sudo")
		if err != nil {
			return runResult{name: "Install Devanagari fonts", out: "sudo not found; install fonts manually", err: fmt.Errorf("sudo missing")}
		}
		tried = append(tried, c.pm)
		res := runCommand("Install Devanagari fonts", sudo, "pacman", "-S", "--needed", "--noconfirm", "noto-fonts")
		if c.pm == "apt-get" {
			res = runCommand("Install Devanagari fonts", sudo, "apt-get", "install", "-y", "fonts-noto")
		}
		if c.pm == "dnf" {
			res = runCommand("Install Devanagari fonts", sudo, "dnf", "install", "-y", "google-noto-sans-devanagari-fonts")
		}
		if res.err == nil {
			return res
		}
	}
	if len(tried) == 0 {
		return runResult{name: "Install Devanagari fonts", out: "No supported package manager found (pacman/apt/dnf).", err: fmt.Errorf("unsupported distro")}
	}
	return runResult{name: "Install Devanagari fonts", out: "All supported package installs failed.", err: fmt.Errorf("package install failed")}
}

func deployEmbedded(name string) string {
	data, err := embeddedScripts.ReadFile("data/" + name)
	if err != nil {
		return ""
	}
	dir, err := os.MkdirTemp("", "nepali-tui-*")
	if err != nil {
		return ""
	}
	path := filepath.Join(dir, name)
	if err := os.WriteFile(path, data, 0755); err != nil {
		return ""
	}
	return path
}

func taskCmd(choice string) tea.Cmd {
	return func() tea.Msg {
		var res runResult
		switch choice {
		case "Install (user-level)":
			script := sidecar("install-nepali-unicode-romanized.sh")
			if script == "" {
				res = runResult{name: choice, out: "installer script not found next to binary", err: fmt.Errorf("missing script")}
			} else {
				res = runCommand(choice, "bash", script, "--yes")
			}
		case "Install (system-wide)":
			script := sidecar("install-nepali-unicode-romanized.sh")
			if script == "" {
				res = runResult{name: choice, out: "installer script not found next to binary", err: fmt.Errorf("missing script")}
			} else {
				res = runCommand(choice, "bash", script, "--yes", "--system")
			}
		case "Install Devanagari fonts":
			res = runFonts()
		case "Validate layout":
			res = runCommand(choice, "xkbcli", "compile-keymap", "--include", filepath.Join(os.Getenv("HOME"), ".config", "xkb"), "--include-defaults", "--rules", "evdev", "--layout", "nepali_unicode_romanized", "--variant", "unicode_romanized", "--test")
		case "Enable Alt+Shift toggle (apply)":
			script := sidecar("enable-alt-shift.sh")
			if script == "" {
				res = runResult{name: choice, out: "enable-alt-shift.sh not found", err: fmt.Errorf("missing script")}
			} else {
				res = runCommand(choice, "bash", script, "--apply")
			}
		case "Show verified install command":
			res = runResult{name: choice, out: "tmp=$(mktemp -d)\ncurl -fsSL https://raw.githubusercontent.com/indrakhatiwada/nepali-romanized-unicode-linux/main/install-nepali-unicode-romanized.sh -o \"$tmp/install.sh\"\ncurl -fsSL https://raw.githubusercontent.com/indrakhatiwada/nepali-romanized-unicode-linux/main/install.sha256 -o \"$tmp/install.sha256\"\n(cd \"$tmp\" && sha256sum -c install.sha256) || exit 1\nbash \"$tmp/install.sh\" --yes", err: nil}
		default:
			res = runResult{name: choice, out: "done", err: nil}
		}
		return runDoneMsg(res)
	}
}

func (m model) Init() tea.Cmd {
	return nil
}

func (m model) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg.(type) {
	case tea.WindowSizeMsg:
		wm := msg.(tea.WindowSizeMsg)
		m.width = wm.Width
		m.height = wm.Height
		m.menu.SetSize(wm.Width, wm.Height-4)
		m.log.Width = wm.Width
		m.log.Height = wm.Height - 4
		return m, nil
	case tea.KeyMsg:
		k := msg.(tea.KeyMsg)
		switch m.state {
		case stateMenu:
			if k.Type == tea.KeyCtrlC || k.String() == "q" {
				return m, tea.Quit
			}
			if k.String() == "enter" {
				sel, ok := m.menu.SelectedItem().(item)
				if !ok {
					return m, nil
				}
				if sel.title == "Exit" {
					return m, tea.Quit
				}
				m.active = sel.title
				m.state = stateRunning
				return m, tea.Batch(taskCmd(sel.title), m.spin.Tick)
			}
		case stateRunning:
			if k.Type == tea.KeyCtrlC {
				return m, tea.Quit
			}
		case stateDone:
			if k.String() == "q" || k.Type == tea.KeyCtrlC {
				return m, tea.Quit
			}
			if k.String() == "enter" || k.String() == "esc" {
				m.state = stateMenu
				m.log.SetContent("No output yet.")
				return m, nil
			}
		}
	case runDoneMsg:
		r := msg.(runDoneMsg)
		m.active = r.name
		out := r.out
		if r.err != nil {
			out += "\n\nERROR: " + r.err.Error()
		}
		if r.name == "Install (user-level)" && r.err == nil {
			m.userInstalled = true
			m.menu.SetItems(menuItems(m.fontsInstalled, true, m.systemInstalled, m.toggleInstalled))
		}
		if r.name == "Install (system-wide)" && r.err == nil {
			m.systemInstalled = true
			m.menu.SetItems(menuItems(m.fontsInstalled, m.userInstalled, true, m.toggleInstalled))
		}
		if r.name == "Install Devanagari fonts" && r.err == nil {
			m.fontsInstalled = true
			m.menu.SetItems(menuItems(true, m.userInstalled, m.systemInstalled, m.toggleInstalled))
		}
		if r.name == "Enable Alt+Shift toggle (apply)" && r.err == nil {
			m.toggleInstalled = true
			m.menu.SetItems(menuItems(m.fontsInstalled, m.userInstalled, m.systemInstalled, true))
		}
		m.log.SetContent(out)
		m.log.GotoTop()
		m.state = stateDone
		return m, nil
	case spinner.TickMsg:
		if m.state == stateRunning {
			var cmd tea.Cmd
			m.spin, cmd = m.spin.Update(msg)
			return m, cmd
		}
	}
	if m.state == stateMenu {
		var cmd tea.Cmd
		m.menu, cmd = m.menu.Update(msg)
		return m, cmd
	}
	if m.state == stateRunning {
		var cmd tea.Cmd
		m.log, cmd = m.log.Update(msg)
		return m, cmd
	}
	if m.state == stateDone {
		var cmd tea.Cmd
		m.log, cmd = m.log.Update(msg)
		return m, cmd
	}
	return m, nil
}

func (m model) View() string {
	switch m.state {
	case stateRunning:
		return m.spin.View() + " " + m.active + " ...\n\n" + m.log.View()
	case stateDone:
		header := lipgloss.NewStyle().Bold(true).Foreground(lipgloss.Color("2")).Render("Finished: " + m.active)
		return header + "\n\n" + m.log.View() + "\n\nPress Enter/Esc to return, q to quit."
	default:
		return m.menu.View() + "\n" + lipgloss.NewStyle().Foreground(lipgloss.Color("8")).Render("Use arrow keys + Enter. q to quit.")
	}
}

func main() {
	p := tea.NewProgram(initialModel(), tea.WithAltScreen())
	if _, err := p.Run(); err != nil {
		os.Exit(1)
	}
}
