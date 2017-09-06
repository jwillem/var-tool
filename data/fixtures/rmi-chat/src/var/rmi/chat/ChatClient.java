package var.rmi.chat;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.net.MalformedURLException;
import java.rmi.Naming;
import java.rmi.NotBoundException;
import java.rmi.RemoteException;
import java.rmi.server.UnicastRemoteObject;

public class ChatClient extends UnicastRemoteObject implements ChatClientInterface {
	private static final long serialVersionUID = 2567946040561879496L;
	private String username;
	private ChatServerInterface remote;

	public ChatClient(String username) throws MalformedURLException, RemoteException, NotBoundException, IOException  {
		this.username = username;
		remote = (ChatServerInterface) Naming.lookup(Conf.CHATSERVICE);
		remote.enter(this.username, this);
		BufferedReader input = new BufferedReader(new InputStreamReader(System.in));
		String line = "";
		while (!line.equalsIgnoreCase("leave chat")) {
			line = input.readLine();
			sendMessage(line);
		}
		remote.leave(this);
		System.exit(0);
	}

	@Override
	public void receiveMessage(String message, String sender) {
		System.out.println(sender + ": " + message + "\n");
	}

	public void sendMessage(String message) throws RemoteException {
		remote.postMessage(message, username);
	}

	@Override
	public String getUser() throws RemoteException {
		return username;
	}

	public static void main(String[] args) throws Exception {
		new ChatClient(args[0]);
	}
}