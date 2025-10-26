//
//  ChatBotItem.swift
//  HackMTY2025
//
//  Created by FurryVale on 10/25/25.
//

import SwiftUI

struct ChatBotItem: View{
    let message: String
    let isFromUser: Bool
    let avatarimg: String
    
    var body: some View{
        HStack(alignment: .top, spacing: 12){
            if !isFromUser{
                Image(avatarimg).resizable()
                    .scaledToFill()
                    .frame(width: 48, height:48)
                    .clipShape(Circle())
            }
            
            Text(message).padding().background(
                RoundedRectangle(cornerRadius: 16).stroke(Color.gray.opacity(0.4))
            )
            .foregroundColor(.black)
            .multilineTextAlignment(.leading)
            .frame(maxWidth: .infinity, alignment: isFromUser ? .trailing: .leading)
            
            if isFromUser{
                Image(avatarimg)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height:48)
                    .clipShape(Circle())
            }
        }
        .frame(maxWidth: .infinity, alignment: isFromUser ? .trailing: .leading)
        .padding(isFromUser ? .leading: .trailing, 50)
        .padding(.vertical, 8)
    }
}

