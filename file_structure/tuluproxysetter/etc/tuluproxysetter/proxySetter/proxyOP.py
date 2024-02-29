import subprocess, os
import json
import argparse
import time

home_path = os.environ['HOME']
autoProxy_folder_path = home_path + "/.tuluproxysetter"
proxyVars_folder_path = autoProxy_folder_path + "/proxyVars"
autoStartFiles_folder_path = autoProxy_folder_path + "/autoStartFiles"
proxySetter_folder_path = "/etc/tuluproxysetter/proxySetter"
autostart_desktop_folder_path = home_path + "/.config/autostart"

home_proxy_path = proxyVars_folder_path + "/proxy"
autoStart_shell_path = autoStartFiles_folder_path + "/tuluautoproxy.sh"
autoStart_list_proxy_path = autoStartFiles_folder_path + "/proxies.json"

bashrc_path = home_path + "/.bashrc"
zshrc_path = home_path + "/.zshrc"

autoStart_desktop_path = autostart_desktop_folder_path + '/tuluautoproxy.desktop'

python_filepath = proxySetter_folder_path + "/proxyOP.py"

proxy_types = ["http_proxy", "https_proxy", "ftp_proxy", "HTTP_PROXY", "HTTPS_PROXY", "FTP_PROXY"]

def check_connected_wifi():
    try:
        return subprocess.check_output("iwgetid -r", shell=True, executable="/bin/bash").decode('utf-8')[0:-1]
    except:
        return ""

class ProxySetter:
    def __init__(self):
        self.create_files(autoStart_shell_path)
        self.add_proxy_shell(bashrc_path)
        self.add_proxy_shell(zshrc_path)

    def add_proxy_shell(self,filepath):
        content = "[[ -f ~/.tuluproxysetter/proxyVars/proxy ]] && source ~/.tuluproxysetter/proxyVars/proxy"
        try:
            with open(filepath) as fptr:
                for line in fptr.readlines():
                    if content in line.replace("\n", ""):
                        return

            file = open(filepath, "a")
            file.write("\n" + content)

            file.close()
        except:
            print("File Not Found")
    
    def create_files(self, filepath):
        if not os.path.isfile(filepath):
            subprocess.run(f"install -Dv /dev/null {autoStart_shell_path}", shell=True, executable="/bin/bash")

    def set_proxy(self, proxy_info):
        ## add proxy for this user
        proxy_addr = proxy_info[1] + ":" + proxy_info[2]
        file = open(home_proxy_path, "w")

        file.write(f"#network_name={proxy_info[0]}\n")
        for proxy_type in proxy_types:
            file.write(f"export {proxy_type}={proxy_addr}\n")

        file.write(f"export no_proxy={proxy_info[3]}\n")
        file.write(f"export NO_PROXY={proxy_info[3]}")

        file.close()

        ## gnome settings to set proxy
        # first remove any existing proxy
        subprocess.run("gsettings set org.gnome.system.proxy mode 'none'", shell=True, executable="/bin/bash")

        # now set proxy
        subprocess.run("gsettings set org.gnome.system.proxy mode 'manual'", shell=True, executable="/bin/bash")
        subprocess.run("gsettings set org.gnome.system.proxy.http enabled true", shell=True, executable="/bin/bash")
        subprocess.run(f"gsettings set org.gnome.system.proxy.http host {proxy_info[1]}", shell=True, executable="/bin/bash")
        subprocess.run(f"gsettings set org.gnome.system.proxy.http port {proxy_info[2]}", shell=True, executable="/bin/bash")
        subprocess.run(f"gsettings set org.gnome.system.proxy.https host {proxy_info[1]}", shell=True, executable="/bin/bash")
        subprocess.run(f"gsettings set org.gnome.system.proxy.https port {proxy_info[2]}", shell=True, executable="/bin/bash")
        subprocess.run(f"gsettings set org.gnome.system.proxy.ftp host {proxy_info[1]}", shell=True, executable="/bin/bash")
        subprocess.run(f"gsettings set org.gnome.system.proxy.ftp port {proxy_info[2]}", shell=True, executable="/bin/bash")
        subprocess.run(f"gsettings set org.gnome.system.proxy.socks host {proxy_info[1]}", shell=True, executable="/bin/bash")
        subprocess.run(f"gsettings set org.gnome.system.proxy.socks port {proxy_info[2]}", shell=True, executable="/bin/bash")

        # now set up for no proxy
        gnome_no_proxies = "["
        for ip in proxy_info[3].split(","):
            gnome_no_proxies = gnome_no_proxies + f"'{ip}', "
        gnome_no_proxies = gnome_no_proxies[0:-2] + "]"

        # print(gnome_no_proxies)

        subprocess.run(f'gsettings set org.gnome.system.proxy ignore-hosts "{gnome_no_proxies}"', shell=True, executable="/bin/bash")
        
    def remove_proxy(self):
        os.remove(home_proxy_path)

        ## remove gnome proxy
        subprocess.run("gsettings set org.gnome.system.proxy mode 'none'", shell=True, executable="/bin/bash")

    def add_desktop_file(self):
        # lines to write for gnome
        lines = ["[Desktop Entry]\n",
                    f"Exec={autoStart_shell_path}\n",
                    "Icon=dialog-scripts\n",
                    "Name=tulu_auto_proxy\n",
                    "Type=Application\n",
                    "X-GNOME-AutostartScript=true"]
        
        if(os.environ["DESKTOP_SESSION"]=="plasma"):
            lines[-1] = "X-KDE-AutostartScript=true"

        print(autoStart_desktop_path)

        file = open(autoStart_desktop_path, "w")
        file.writelines(lines)
        file.close()

    def remove_desktop_file(self):
        os.remove(autoStart_desktop_path)

    def auto_list(self):
        # create a script which will run this python file in run list function
        file = open(autoStart_shell_path, "w")
        file.write("#!/bin/bash\n")
        file.write(f"python3 {python_filepath} --rl")
        file.close()
        # add executable permission
        subprocess.run(f"chmod +x {autoStart_shell_path}", shell=True, executable="/bin/bash")
        # create a desktop file
        self.add_desktop_file()
        pass

    def run_list(self):
        # in an infinite while loop read data from proxy list
        prev_connected_wifi = ""
        while(1):
            # read proxy file
            try:
                file = open(autoStart_list_proxy_path)
                jsonData = json.load(file)
                file.close()
            except:
                break

            #check wifi name
            connected_wifi = check_connected_wifi()

            # is wifi name different then change proxy
            if connected_wifi != prev_connected_wifi and connected_wifi != "":
                isFound = False
                for proxy in jsonData:
                    if proxy["name"] == connected_wifi:
                        isFound = True
                        self.set_proxy([proxy["name"], proxy["host"], proxy["port"], proxy["noProxy"]])
                        print("Proxy Set")
                        break
                if not isFound:
                    self.remove_proxy()
                    print("proxy removed")
                prev_connected_wifi = connected_wifi

            time.sleep(2)

        



def get_home_path():
    return os.environ['HOME']


def read_json(json_filepath):
    file = open(json_filepath)
    content = json.load(file)
    file.close()
    return content


def get_arguments():
    parser = argparse.ArgumentParser(description="desc")
    parser.add_argument("-s", "--set", dest="set", nargs=4, help = "add a proxy")
    parser.add_argument("-u", "--unset", dest="unset", action="store_true", help="remove proxy")
    parser.add_argument("-l", "--list",dest="autoList", action="store_true", help="write auto start proxy list desktop file")
    parser.add_argument("--ra", dest="rmauto", action="store_true", help="remove autoproxy desktop file")
    parser.add_argument("--rl", dest="runList", action="store_true", help="run autoProxy from proxy list")
    args = vars(parser.parse_args())
    return args


if __name__ == "__main__":

    options = get_arguments()

    ps = ProxySetter()

    if options['set']:
        ps.set_proxy(options['set'])
    if options['unset']:
        ps.remove_proxy()
    if options['autoList']:
        ps.auto_list()
    if options['rmauto']:
        ps.remove_desktop_file()
    if options['runList']:
        ps.run_list()
        
    print(options)
