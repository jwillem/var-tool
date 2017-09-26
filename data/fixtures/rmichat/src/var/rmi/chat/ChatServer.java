package var.rmi.chat;

import java.rmi.Naming;
import java.rmi.RemoteException;
import java.rmi.registry.LocateRegistry;
import java.rmi.server.UnicastRemoteObject;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

public class ChatServer extends UnicastRemoteObject implements ChatServerInterface {
	private static final long serialVersionUID = -4414221617713823464L;
	List<ChatClientInterface> remoteClients = Collections.synchronizedList(new ArrayList<ChatClientInterface>());

	public ChatServer() throws RemoteException {
	}

	@Override
	public void enter(String username, ChatClientInterface remoteClient) throws RemoteException {
		System.out.println("A new user with name " + username + " joined.\n");
		postMessage(username + " enters", "sysop");
		remoteClients.add(remoteClient);
	}

	@Override
	public void leave(ChatClientInterface remoteClient) throws RemoteException {
                String username = remoteClient.getUser();
		System.out.println("User with name " + username + " left.\n");
		postMessage(username + " leaves", "sysop");
		remoteClients.remove(remoteClient);
	}

	@Override
	public void postMessage(String message, String user) {
		for (ChatClientInterface remote : remoteClients) {
			try {
				remote.receiveMessage(message, user);
			} catch (RemoteException ex) {
				// z.B. Verbindungsfehler
			}
		}
	}

	public static void main(String args[]) {
		try {
			LocateRegistry.createRegistry(1099);
			Naming.rebind(Conf.CHATSERVICE, new ChatServer());
		        System.out.println("Server was started on port " + 1099 + ".\n");
		} catch (Exception ex) {
			ex.printStackTrace();
		}
	}
}
