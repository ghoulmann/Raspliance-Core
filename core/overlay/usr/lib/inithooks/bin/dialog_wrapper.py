# Copyright (c) 2010 Alon Swartz <alon@turnkeylinux.org> - all rights reserved

import re
import os
import sys
import dialog
import traceback
from StringIO import StringIO

import executil

email_re = re.compile(r"(?:^|\s)[-a-z0-9_.]+@(?:[-a-z0-9]+\.)+[a-z]{2,6}(?:\s|$)",re.IGNORECASE)

class Error(Exception):
    pass

class Dialog:
    def __init__(self, title, width=60, height=20):
        self.width = width
        self.height = height

        self.console = dialog.Dialog(dialog="dialog")
        self.console.add_persistent_args(["--no-collapse"])
        self.console.add_persistent_args(["--backtitle", title])

    def _handle_exitcode(self, retcode):
        if retcode == 2: # ESC, ALT+?
            text = "Do you really want to quit?"
            if self.console.yesno(text) == 0:
                sys.exit(0)
            return False
        return True

    def _calc_height(self, text):
        height = 6
        for line in text.splitlines():
            height += (len(line) / self.width) + 1

        return height

    def wrapper(self, dialog, text, *args, **kws):
        try:
            method = getattr(self.console, dialog)
        except AttibuteError:
            raise Error("dialog not supported: " + dialog)

        while 1:
            try:
                ret = method("\n" + text, *args, **kws)
                if type(ret) is int:
                    retcode = ret
                else:
                    retcode = ret[0]

                if self._handle_exitcode(retcode):
                    break

            except Exception, e:
                sio = StringIO()
                traceback.print_exc(file=sio)

                self.msgbox("Caught exception", sio.getvalue())

        return ret

    def error(self, text):
        height = self._calc_height(text)
        return self.wrapper("msgbox", text, height, self.width, title="Error")

    def msgbox(self, title, text):
        height = self._calc_height(text)
        return self.wrapper("msgbox", text, height, self.width, title=title)

    def infobox(self, text):
        height = self._calc_height(text)
        return self.wrapper("infobox", text, height, self.width)

    def inputbox(self, title, text, init='', ok_label="OK", cancel_label="Cancel"):
        height = self._calc_height(text) + 3
        no_cancel = True if cancel_label == "" else False
        return self.wrapper("inputbox", text, height, self.width, title=title, 
                            init=init, ok_label=ok_label, cancel_label=cancel_label,
                            no_cancel=no_cancel)

    def yesno(self, title, text, yes_label="Yes", no_label="No"):
        height = self._calc_height(text)
        retcode = self.wrapper("yesno", text, height, self.width, title=title,
                               yes_label=yes_label, no_label=no_label)

        return True if retcode is 0 else False

    def get_password(self, title, text, min_length=1):
        def ask(title, text):
            return self.wrapper('passwordbox', text, title=title, 
                                ok_label='OK', no_cancel='True')[1]

        while 1:
            password = ask(title, text)
            if len(password) < min_length:
                error = "Password must be at least %s characters." % min_length
                if not password:
                    error = "Please enter non-empty password."

                self.error(error)
                continue

            if password == ask(title, 'Confirm password'):
                return password

            self.error('Password mismatch, please try again.')

    def get_email(self, title, text, init=''):
        while 1:
            email = self.inputbox(title, text, init, "Apply", "")[1]
            if not email:
                self.error('Email is required.')
                continue

            if not email_re.match(email):
                self.error('Email is not valid')
                continue

            return email

    def get_input(self, title, text, init=''):
        while 1:
            input = self.inputbox(title, text, init, "Apply", "")[1]
            if not input:
                self.error('%s is required.' % title)
                continue

            return input
